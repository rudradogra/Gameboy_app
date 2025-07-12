const express = require('express');
const { body, validationResult } = require('express-validator');
const { supabase } = require('../config/supabase');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// Get user profile
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const { data: user, error } = await supabase
      .from('users')
      .select('id, email, username, name, created_at, last_login')
      .eq('id', req.user.id)
      .single();

    if (error) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    res.json({
      user
    });

  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({
      error: 'Failed to fetch user profile'
    });
  }
});

// Update user profile
router.put('/me', authenticateToken, [
  body('name').optional().notEmpty().withMessage('Name cannot be empty'),
  body('username').optional().isLength({ min: 3 }).withMessage('Username must be at least 3 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { name, username } = req.body;
    const updateData = {};

    if (name !== undefined) updateData.name = name;
    if (username !== undefined) {
      // Check if username is already taken
      const { data: existingUser } = await supabase
        .from('users')
        .select('id')
        .eq('username', username)
        .neq('id', req.user.id)
        .single();

      if (existingUser) {
        return res.status(409).json({
          error: 'Username already taken'
        });
      }
      updateData.username = username;
    }

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({
        error: 'No valid fields to update'
      });
    }

    updateData.updated_at = new Date().toISOString();

    const { data: user, error } = await supabase
      .from('users')
      .update(updateData)
      .eq('id', req.user.id)
      .select('id, email, username, name, created_at, last_login, updated_at')
      .single();

    if (error) {
      console.error('Update user error:', error);
      return res.status(500).json({
        error: 'Failed to update user profile'
      });
    }

    res.json({
      message: 'Profile updated successfully',
      user
    });

  } catch (error) {
    console.error('Update user profile error:', error);
    res.status(500).json({
      error: 'Failed to update user profile'
    });
  }
});

// Delete user account
router.delete('/me', authenticateToken, async (req, res) => {
  try {
    // Delete user's profile first (if exists)
    await supabase
      .from('profiles')
      .delete()
      .eq('user_id', req.user.id);

    // Delete user's matches
    await supabase
      .from('matches')
      .delete()
      .or(`user1_id.eq.${req.user.id},user2_id.eq.${req.user.id}`);

    // Delete user account
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('id', req.user.id);

    if (error) {
      console.error('Delete user error:', error);
      return res.status(500).json({
        error: 'Failed to delete user account'
      });
    }

    res.json({
      message: 'Account deleted successfully'
    });

  } catch (error) {
    console.error('Delete user account error:', error);
    res.status(500).json({
      error: 'Failed to delete user account'
    });
  }
});

module.exports = router;
