const express = require('express');
const { body, validationResult } = require('express-validator');
const { supabase, supabaseAdmin } = require('../config/supabase');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// Create a match (like/superlike/pass)
router.post('/', authenticateToken, [
  body('target_user_id').isUUID().withMessage('Target user ID must be a valid UUID'),
  body('action').isIn(['like', 'superlike', 'pass']).withMessage('Action must be like, superlike, or pass')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { target_user_id, action } = req.body;

    // Prevent self-matching
    if (target_user_id === req.user.id) {
      return res.status(400).json({
        error: 'Cannot match with yourself'
      });
    }

    // Check if already interacted with this user
    const { data: existingMatch } = await supabaseAdmin
      .from('matches')
      .select('*')
      .eq('user1_id', req.user.id)
      .eq('user2_id', target_user_id)
      .single();

    if (existingMatch) {
      return res.status(409).json({
        error: 'Already interacted with this user'
      });
    }

    // Create the match record
    const matchData = {
      user1_id: req.user.id,
      user2_id: target_user_id,
      user1_action: action,
      created_at: new Date().toISOString()
    };

    const { data: newMatch, error } = await supabaseAdmin
      .from('matches')
      .insert(matchData)
      .select()
      .single();

    if (error) {
      console.error('Create match error:', error);
      return res.status(500).json({
        error: 'Failed to create match'
      });
    }

    // Check if the other user also liked this user (mutual match)
    let isMatch = false;
    let mutualMatch = null;

    if (action === 'like' || action === 'superlike') {
      const { data: reverseMatch } = await supabaseAdmin
        .from('matches')
        .select('*')
        .eq('user1_id', target_user_id)
        .eq('user2_id', req.user.id)
        .in('user1_action', ['like', 'superlike'])
        .single();

      if (reverseMatch) {
        isMatch = true;
        
        // Update both matches to indicate they're mutual
        await supabaseAdmin
          .from('matches')
          .update({ 
            is_mutual: true,
            updated_at: new Date().toISOString()
          })
          .eq('id', newMatch.id);

        await supabaseAdmin
          .from('matches')
          .update({ 
            is_mutual: true,
            updated_at: new Date().toISOString()
          })
          .eq('id', reverseMatch.id);

        mutualMatch = {
          ...newMatch,
          is_mutual: true
        };
      }
    }

    res.status(201).json({
      message: isMatch ? 'It\'s a match! 🎉' : 'Action recorded successfully',
      match: mutualMatch || newMatch,
      is_mutual: isMatch
    });

  } catch (error) {
    console.error('Create match error:', error);
    res.status(500).json({
      error: 'Failed to process match'
    });
  }
});

// Get user's matches
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const includeAll = req.query.include_all === 'true';
    
    let query = supabase
      .from('matches')
      .select(`
        *,
        user1:users!matches_user1_id_fkey(id, username, name),
        user2:users!matches_user2_id_fkey(id, username, name),
        user1_profile:profiles!matches_user1_id_fkey(age, bio, image_urls),
        user2_profile:profiles!matches_user2_id_fkey(age, bio, image_urls)
      `)
      .or(`user1_id.eq.${req.user.id},user2_id.eq.${req.user.id}`)
      .order('created_at', { ascending: false });

    // If not including all, only show mutual matches
    if (!includeAll) {
      query = query.eq('is_mutual', true);
    }

    const { data: matches, error } = await query;

    if (error) {
      console.error('Get matches error:', error);
      return res.status(500).json({
        error: 'Failed to fetch matches'
      });
    }

    // Format the response to make it easier to work with
    const formattedMatches = matches.map(match => {
      const isCurrentUserUser1 = match.user1_id === req.user.id;
      const otherUser = isCurrentUserUser1 ? match.user2 : match.user1;
      const otherUserProfile = isCurrentUserUser1 ? match.user2_profile : match.user1_profile;
      const currentUserAction = isCurrentUserUser1 ? match.user1_action : match.user2_action;
      const otherUserAction = isCurrentUserUser1 ? match.user2_action : match.user1_action;

      return {
        id: match.id,
        other_user: {
          ...otherUser,
          profile: otherUserProfile
        },
        current_user_action: currentUserAction,
        other_user_action: otherUserAction,
        is_mutual: match.is_mutual,
        created_at: match.created_at,
        updated_at: match.updated_at
      };
    });

    res.json({
      matches: formattedMatches,
      total: formattedMatches.length
    });

  } catch (error) {
    console.error('Get matches error:', error);
    res.status(500).json({
      error: 'Failed to fetch matches'
    });
  }
});

// Get mutual matches only
router.get('/mutual', authenticateToken, async (req, res) => {
  try {
    const { data: matches, error } = await supabaseAdmin
      .from('matches')
      .select(`
        *,
        user1:users!matches_user1_id_fkey(id, username, name),
        user2:users!matches_user2_id_fkey(id, username, name),
        user1_profile:profiles!matches_user1_id_fkey(age, bio, image_urls),
        user2_profile:profiles!matches_user2_id_fkey(age, bio, image_urls)
      `)
      .or(`user1_id.eq.${req.user.id},user2_id.eq.${req.user.id}`)
      .eq('is_mutual', true)
      .order('updated_at', { ascending: false });

    if (error) {
      console.error('Get mutual matches error:', error);
      return res.status(500).json({
        error: 'Failed to fetch mutual matches'
      });
    }

    // Format the response
    const formattedMatches = matches.map(match => {
      const isCurrentUserUser1 = match.user1_id === req.user.id;
      const otherUser = isCurrentUserUser1 ? match.user2 : match.user1;
      const otherUserProfile = isCurrentUserUser1 ? match.user2_profile : match.user1_profile;

      return {
        id: match.id,
        other_user: {
          ...otherUser,
          profile: otherUserProfile
        },
        matched_at: match.updated_at || match.created_at
      };
    });

    res.json({
      matches: formattedMatches,
      total: formattedMatches.length
    });

  } catch (error) {
    console.error('Get mutual matches error:', error);
    res.status(500).json({
      error: 'Failed to fetch mutual matches'
    });
  }
});

// Unmatch (remove a mutual match)
router.delete('/:matchId', authenticateToken, async (req, res) => {
  try {
    const { matchId } = req.params;

    // First, verify the user is part of this match
    const { data: match, error: fetchError } = await supabaseAdmin
      .from('matches')
      .select('*')
      .eq('id', matchId)
      .or(`user1_id.eq.${req.user.id},user2_id.eq.${req.user.id}`)
      .single();

    if (fetchError || !match) {
      return res.status(404).json({
        error: 'Match not found'
      });
    }

    // Delete the match
    const { error } = await supabaseAdmin
      .from('matches')
      .delete()
      .eq('id', matchId);

    if (error) {
      console.error('Delete match error:', error);
      return res.status(500).json({
        error: 'Failed to unmatch'
      });
    }

    res.json({
      message: 'Unmatched successfully'
    });

  } catch (error) {
    console.error('Unmatch error:', error);
    res.status(500).json({
      error: 'Failed to unmatch'
    });
  }
});

module.exports = router;
