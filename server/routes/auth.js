const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { supabase } = require('../config/supabase');

const router = express.Router();

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// Validation middleware
const registerValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('username').isLength({ min: 3 }).withMessage('Username must be at least 3 characters'),
  body('name').notEmpty().withMessage('Name is required')
];

const loginValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty().withMessage('Password is required')
];

// Register new user
router.post('/register', registerValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password, username, name } = req.body;

    // Check if user already exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('email, username')
      .or(`email.eq.${email},username.eq.${username}`)
      .single();

    if (existingUser) {
      return res.status(409).json({
        error: 'User already exists',
        message: 'Email or username is already registered'
      });
    }

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user in Supabase
    const { data: user, error } = await supabase
      .from('users')
      .insert({
        email,
        username,
        name,
        password_hash: hashedPassword,
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) {
      console.error('Database error:', error);
      return res.status(500).json({
        error: 'Failed to create user',
        message: 'Database error occurred'
      });
    }

    // Generate token
    const token = generateToken(user.id);

    // Remove password from response
    const { password_hash, ...userResponse } = user;

    res.status(201).json({
      message: 'User registered successfully',
      user: userResponse,
      token
    });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      error: 'Registration failed',
      message: 'Internal server error'
    });
  }
});

// Login user
router.post('/login', loginValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Get user from database
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error || !user) {
      return res.status(401).json({
        error: 'Invalid credentials',
        message: 'Email or password is incorrect'
      });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({
        error: 'Invalid credentials',
        message: 'Email or password is incorrect'
      });
    }

    // Update last login
    await supabase
      .from('users')
      .update({ last_login: new Date().toISOString() })
      .eq('id', user.id);

    // Generate token
    const token = generateToken(user.id);

    // Remove password from response
    const { password_hash, ...userResponse } = user;

    res.json({
      message: 'Login successful',
      user: userResponse,
      token
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'Login failed',
      message: 'Internal server error'
    });
  }
});

// Verify token endpoint
router.get('/verify', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'No token provided',
        valid: false
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const { data: user, error } = await supabase
      .from('users')
      .select('id, email, username, name, created_at, last_login')
      .eq('id', decoded.userId)
      .single();

    if (error || !user) {
      return res.status(401).json({
        error: 'Invalid token',
        valid: false
      });
    }

    res.json({
      valid: true,
      user
    });

  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({
      error: 'Invalid token',
      valid: false
    });
  }
});

module.exports = router;
