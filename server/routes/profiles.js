const express = require('express');
const { body, validationResult } = require('express-validator');
const { supabase, supabaseAdmin } = require('../config/supabase');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// Get all profiles for discovery (excluding current user)
router.get('/discover', authenticateToken, async (req, res) => {
  try {
    console.log('🔍 Discovery endpoint called by user:', req.user.id);
    
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    console.log(`📊 Discovery params - page: ${page}, limit: ${limit}, offset: ${offset}`);

    // Get profiles that the current user hasn't interacted with yet
    console.log('🗄️ Fetching profiles from database...');
    const { data: profiles, error } = await supabaseAdmin
      .from('profiles')
      .select(`
        *,
        users!profiles_user_id_fkey(username, name)
      `)
      .neq('user_id', req.user.id)
      .eq('is_active', true)
      .range(offset, offset + limit - 1);

    if (error) {
      console.error('❌ Get profiles error:', error);
      return res.status(500).json({
        error: 'Failed to fetch profiles'
      });
    }

    console.log(`✅ Found ${profiles?.length || 0} profiles before filtering`);
    console.log('📋 Raw profiles data:', profiles?.map(p => ({ id: p.id, name: p.name, user_id: p.user_id })));

    // Filter out profiles that user has already liked/passed
    console.log('🔍 Checking for previous interactions...');
    const { data: interactions } = await supabaseAdmin
      .from('matches')
      .select('user2_id')
      .eq('user1_id', req.user.id);

    console.log(`📝 Found ${interactions?.length || 0} previous interactions:`, interactions?.map(i => i.user2_id));

    const interactedUserIds = new Set(interactions?.map(i => i.user2_id) || []);
    const filteredProfiles = profiles.filter(profile => !interactedUserIds.has(profile.user_id));

    console.log(`✅ After filtering: ${filteredProfiles.length} profiles available`);

    res.json({
      profiles: filteredProfiles,
      page,
      limit,
      total: filteredProfiles.length
    });

    console.log('📤 Successfully sent discovery response');

  } catch (error) {
    console.error('💥 Discover profiles error:', error);
    res.status(500).json({
      error: 'Failed to discover profiles'
    });
  }
});

// Get current user's profile
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const { data: profile, error } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('user_id', req.user.id)
      .single();

    if (error && error.code !== 'PGRST116') { // PGRST116 = not found
      console.error('Get profile error:', error);
      return res.status(500).json({
        error: 'Failed to fetch profile'
      });
    }

    if (!profile) {
      return res.status(404).json({
        error: 'Profile not found',
        message: 'Please create your profile first'
      });
    }

    res.json({
      profile
    });

  } catch (error) {
    console.error('Get my profile error:', error);
    res.status(500).json({
      error: 'Failed to fetch profile'
    });
  }
});

// Create or update user profile
router.post('/me', authenticateToken, [
  body('age').isInt({ min: 18, max: 100 }).withMessage('Age must be between 18 and 100'),
  body('bio').optional().isLength({ max: 500 }).withMessage('Bio must be less than 500 characters'),
  body('interests').optional().isArray().withMessage('Interests must be an array'),
  body('location').optional().notEmpty().withMessage('Location cannot be empty'),
  body('image_urls').optional().isArray().withMessage('Image URLs must be an array')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { age, bio, interests, location, image_urls } = req.body;

    const profileData = {
      name: req.body.name,
      user_id: req.user.id,
      age,
      bio: bio || '',
      interests: interests || [],
      location: location || '',
      image_urls: image_urls || [],
      is_active: true,
      updated_at: new Date().toISOString()
    };

    // Check if profile exists
    const { data: existingProfile } = await supabaseAdmin
      .from('profiles')
      .select('id')
      .eq('user_id', req.user.id)
      .single();

    let result;
    if (existingProfile) {
      // Update existing profile
      result = await supabaseAdmin
        .from('profiles')
        .update(profileData)
        .eq('user_id', req.user.id)
        .select()
        .single();
    } else {
      // Create new profile
      profileData.created_at = new Date().toISOString();
      result = await supabaseAdmin
        .from('profiles')
        .insert(profileData)
        .select()
        .single();
    }

    if (result.error) {
      console.error('Profile operation error:', result.error);
      return res.status(500).json({
        error: 'Failed to save profile'
      });
    }

    res.json({
      message: existingProfile ? 'Profile updated successfully' : 'Profile created successfully',
      profile: result.data
    });

  } catch (error) {
    console.error('Save profile error:', error);
    res.status(500).json({
      error: 'Failed to save profile'
    });
  }
});

// Get specific profile by ID
router.get('/:profileId', authenticateToken, async (req, res) => {
  try {
    const { profileId } = req.params;

    const { data: profile, error } = await supabaseAdmin
      .from('profiles')
      .select(`
        *,
        users!profiles_user_id_fkey(username, name)
      `)
      .eq('id', profileId)
      .eq('is_active', true)
      .single();

    if (error) {
      return res.status(404).json({
        error: 'Profile not found'
      });
    }

    // Don't allow users to view their own profile through this endpoint
    if (profile.user_id === req.user.id) {
      return res.status(403).json({
        error: 'Cannot view your own profile through this endpoint'
      });
    }

    res.json({
      profile
    });

  } catch (error) {
    console.error('Get profile by ID error:', error);
    res.status(500).json({
      error: 'Failed to fetch profile'
    });
  }
});

// Update user's own profile
router.put('/me', authenticateToken, [
  body('bio').optional().isLength({ max: 500 }).withMessage('Bio must be less than 500 characters'),
  body('age').optional().isInt({ min: 18, max: 99 }).withMessage('Age must be between 18 and 99'),
  body('location').optional().isLength({ max: 100 }).withMessage('Location must be less than 100 characters'),
  body('images').optional().isArray().withMessage('Images must be an array'),
  body('images.*').optional().isURL({
    protocols: ['http', 'https'],
    require_protocol: true,
    allow_underscores: true,
    host_whitelist: ['localhost', '127.0.0.1', '10.0.2.2'] // Allow local development URLs
  }).withMessage('Each image must be a valid URL'),
  body('interests').optional().isArray().withMessage('Interests must be an array'),
  body('name').optional().notEmpty().withMessage('Name cannot be empty')
], async (req, res) => {
  try {
    console.log('🔄 Profile update request received');
    console.log('👤 User ID:', req.user.id);
    console.log('📄 Request body:', JSON.stringify(req.body, null, 2));
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('❌ Validation errors:', errors.array());
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { bio, age, location, images, interests, name } = req.body;
    
    // First check if profile exists
    const { data: existingProfile } = await supabaseAdmin
      .from('profiles')
      .select('id')
      .eq('user_id', req.user.id)
      .single();

    const updateData = {};
    if (bio !== undefined) updateData.bio = bio;
    if (age !== undefined) updateData.age = age;
    if (location !== undefined) updateData.location = location;
    if (images !== undefined) updateData.image_urls = images; // Map images to image_urls column
    if (interests !== undefined) updateData.interests = interests;
    if (name !== undefined) updateData.name = name; // Add name to profile update data
    
    updateData.updated_at = new Date().toISOString();

    let profileResult;
    
    if (existingProfile) {
      // Update existing profile
      const { data: profile, error } = await supabaseAdmin
        .from('profiles')
        .update(updateData)
        .eq('user_id', req.user.id)
        .select(`
          *,
          users!profiles_user_id_fkey(username, name)
        `)
        .single();

      if (error) {
        console.error('Update profile error:', error);
        return res.status(500).json({
          error: 'Failed to update profile'
        });
      }
      profileResult = profile;
    } else {
      // Create new profile
      updateData.user_id = req.user.id;
      updateData.is_active = true;

      const { data: profile, error } = await supabaseAdmin
        .from('profiles')
        .insert([updateData])
        .select(`
          *,
          users!profiles_user_id_fkey(username, name)
        `)
        .single();

      if (error) {
        console.error('Create profile error:', error);
        return res.status(500).json({
          error: 'Failed to create profile'
        });
      }
      profileResult = profile;
    }

    // Update user name if provided
    if (name !== undefined) {
      const { error: userError } = await supabaseAdmin
        .from('users')
        .update({ 
          name: name,
          updated_at: new Date().toISOString()
        })
        .eq('id', req.user.id);

      if (userError) {
        console.error('Update user name error:', userError);
        // Don't fail the request, just log the error
      }
    }

    res.json({
      message: 'Profile updated successfully',
      profile: profileResult
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      error: 'Failed to update profile'
    });
  }
});

// Deactivate profile
router.delete('/me', authenticateToken, async (req, res) => {
  try {
    const { data: profile, error } = await supabaseAdmin
      .from('profiles')
      .update({ 
        is_active: false,
        updated_at: new Date().toISOString()
      })
      .eq('user_id', req.user.id)
      .select()
      .single();

    if (error) {
      console.error('Deactivate profile error:', error);
      return res.status(500).json({
        error: 'Failed to deactivate profile'
      });
    }

    res.json({
      message: 'Profile deactivated successfully',
      profile
    });

  } catch (error) {
    console.error('Deactivate profile error:', error);
    res.status(500).json({
      error: 'Failed to deactivate profile'
    });
  }
});

module.exports = router;
