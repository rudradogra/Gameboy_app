const express = require('express');
const { body, validationResult } = require('express-validator');
const { supabase, supabaseAdmin } = require('../config/supabase');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// Get all profiles for discovery (excluding current user)
router.get('/discover', authenticateToken, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Get profiles that the current user hasn't interacted with yet
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
      console.error('Get profiles error:', error);
      return res.status(500).json({
        error: 'Failed to fetch profiles'
      });
    }

    // Filter out profiles that user has already liked/passed
    const { data: interactions } = await supabaseAdmin
      .from('matches')
      .select('user2_id')
      .eq('user1_id', req.user.id);

    const interactedUserIds = new Set(interactions?.map(i => i.user2_id) || []);
    const filteredProfiles = profiles.filter(profile => !interactedUserIds.has(profile.user_id));

    res.json({
      profiles: filteredProfiles,
      page,
      limit,
      total: filteredProfiles.length
    });

  } catch (error) {
    console.error('Discover profiles error:', error);
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
