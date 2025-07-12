const express = require('express');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const { supabase } = require('../config/supabase');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB default
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = process.env.ALLOWED_FILE_TYPES?.split(',') || ['image/jpeg', 'image/png', 'image/jpg'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, and JPG files are allowed.'), false);
    }
  }
});

// Upload single image
router.post('/image', authenticateToken, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No file uploaded'
      });
    }

    // Generate unique filename
    const fileExtension = path.extname(req.file.originalname);
    const fileName = `${req.user.id}/${uuidv4()}${fileExtension}`;

    // Upload to Supabase Storage
    const { data, error } = await supabase.storage
      .from('profile-images')
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        cacheControl: '3600'
      });

    if (error) {
      console.error('Upload error:', error);
      return res.status(500).json({
        error: 'Failed to upload image',
        details: error.message
      });
    }

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('profile-images')
      .getPublicUrl(fileName);

    res.status(201).json({
      message: 'Image uploaded successfully',
      image_url: publicUrl,
      file_path: fileName
    });

  } catch (error) {
    console.error('Upload image error:', error);
    
    if (error.message.includes('Invalid file type')) {
      return res.status(400).json({
        error: error.message
      });
    }
    
    res.status(500).json({
      error: 'Failed to upload image'
    });
  }
});

// Upload multiple images
router.post('/images', authenticateToken, upload.array('images', 6), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        error: 'No files uploaded'
      });
    }

    const uploadPromises = req.files.map(async (file) => {
      const fileExtension = path.extname(file.originalname);
      const fileName = `${req.user.id}/${uuidv4()}${fileExtension}`;

      const { data, error } = await supabase.storage
        .from('profile-images')
        .upload(fileName, file.buffer, {
          contentType: file.mimetype,
          cacheControl: '3600'
        });

      if (error) {
        throw new Error(`Failed to upload ${file.originalname}: ${error.message}`);
      }

      const { data: { publicUrl } } = supabase.storage
        .from('profile-images')
        .getPublicUrl(fileName);

      return {
        original_name: file.originalname,
        image_url: publicUrl,
        file_path: fileName
      };
    });

    const results = await Promise.all(uploadPromises);

    res.status(201).json({
      message: 'Images uploaded successfully',
      images: results
    });

  } catch (error) {
    console.error('Upload images error:', error);
    res.status(500).json({
      error: 'Failed to upload images',
      details: error.message
    });
  }
});

// Delete image
router.delete('/image', authenticateToken, async (req, res) => {
  try {
    const { file_path } = req.body;

    if (!file_path) {
      return res.status(400).json({
        error: 'File path is required'
      });
    }

    // Verify the file belongs to the current user
    if (!file_path.startsWith(req.user.id + '/')) {
      return res.status(403).json({
        error: 'Unauthorized to delete this file'
      });
    }

    const { error } = await supabase.storage
      .from('profile-images')
      .remove([file_path]);

    if (error) {
      console.error('Delete image error:', error);
      return res.status(500).json({
        error: 'Failed to delete image',
        details: error.message
      });
    }

    res.json({
      message: 'Image deleted successfully'
    });

  } catch (error) {
    console.error('Delete image error:', error);
    res.status(500).json({
      error: 'Failed to delete image'
    });
  }
});

// Get user's uploaded images
router.get('/images/me', authenticateToken, async (req, res) => {
  try {
    const { data, error } = await supabase.storage
      .from('profile-images')
      .list(req.user.id, {
        limit: 100,
        sortBy: { column: 'created_at', order: 'desc' }
      });

    if (error) {
      console.error('List images error:', error);
      return res.status(500).json({
        error: 'Failed to fetch images'
      });
    }

    const images = data.map(file => {
      const { data: { publicUrl } } = supabase.storage
        .from('profile-images')
        .getPublicUrl(`${req.user.id}/${file.name}`);

      return {
        name: file.name,
        image_url: publicUrl,
        file_path: `${req.user.id}/${file.name}`,
        created_at: file.created_at,
        size: file.metadata?.size
      };
    });

    res.json({
      images,
      total: images.length
    });

  } catch (error) {
    console.error('Get user images error:', error);
    res.status(500).json({
      error: 'Failed to fetch images'
    });
  }
});

module.exports = router;
