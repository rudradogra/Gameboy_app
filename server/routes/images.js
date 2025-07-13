const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs').promises;
const upload = require('../middleware/upload');
const imageProcessor = require('../services/imageProcessor');
const authMiddleware = require('../middleware/auth');

// Upload and process images
router.post('/upload', authMiddleware, upload.array('images', 3), async (req, res) => {
  try {
    console.log('📤 Image upload request received');
    console.log('👤 User ID:', req.user.id);
    console.log('📁 Files received:', req.files?.length || 0);

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No images provided'
      });
    }

    const processedImages = [];
    
    for (const file of req.files) {
      try {
        console.log(`🔄 Processing image: ${file.filename}`);
        
        // Generate unique filename for processed image
        const processedFilename = `processed_${file.filename}`;
        
        // Process the image to retro style
        await imageProcessor.convertToRetroPixelated(file.path, processedFilename);
        
        // Generate URL for the processed image
        const imageUrl = imageProcessor.getProcessedImageUrl(processedFilename);
        
        processedImages.push({
          originalName: file.originalname,
          filename: processedFilename,
          url: imageUrl,
          size: file.size
        });

        // Clean up original file
        await imageProcessor.deleteFile(file.path);
        
        console.log(`✅ Successfully processed: ${file.originalname}`);
      } catch (error) {
        console.error(`❌ Error processing ${file.filename}:`, error);
        // Clean up files on error
        try {
          await imageProcessor.deleteFile(file.path);
        } catch {}
      }
    }

    if (processedImages.length === 0) {
      return res.status(500).json({
        success: false,
        message: 'Failed to process any images'
      });
    }

    console.log(`✅ Successfully processed ${processedImages.length} images`);
    
    res.json({
      success: true,
      message: `Successfully processed ${processedImages.length} image(s)`,
      data: {
        images: processedImages
      }
    });

  } catch (error) {
    console.error('💥 Image upload error:', error);
    
    // Clean up any uploaded files on error
    if (req.files) {
      for (const file of req.files) {
        try {
          await imageProcessor.deleteFile(file.path);
        } catch {}
      }
    }
    
    res.status(500).json({
      success: false,
      message: 'Image upload failed',
      error: error.message
    });
  }
});

// Serve processed images
router.get('/:filename', (req, res) => {
  const filename = req.params.filename;
  const imagePath = path.join(__dirname, '../uploads/processed', filename);
  
  console.log(`📷 Serving image: ${filename}`);
  
  // Check if file exists and serve it
  res.sendFile(imagePath, (err) => {
    if (err) {
      console.error(`❌ Error serving image ${filename}:`, err);
      res.status(404).json({
        success: false,
        message: 'Image not found'
      });
    }
  });
});

// Delete image
router.delete('/:filename', authMiddleware, async (req, res) => {
  try {
    const filename = req.params.filename;
    const imagePath = path.join(__dirname, '../uploads/processed', filename);
    
    console.log(`🗑️ Deleting image: ${filename}`);
    
    await imageProcessor.deleteFile(imagePath);
    
    res.json({
      success: true,
      message: 'Image deleted successfully'
    });
    
  } catch (error) {
    console.error('❌ Error deleting image:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete image',
      error: error.message
    });
  }
});

// Get image preview (GameBoy style)
router.post('/preview', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    console.log('👁️ Image preview request');
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image provided for preview'
      });
    }

    // Generate unique filename for preview
    const previewFilename = `preview_${req.file.filename}`;
    
    // Process image in GameBoy style for preview
    await imageProcessor.convertToGameBoyStyle(req.file.path, previewFilename);
    
    const previewUrl = imageProcessor.getProcessedImageUrl(previewFilename);
    
    // Clean up original file
    await imageProcessor.deleteFile(req.file.path);
    
    res.json({
      success: true,
      message: 'Preview generated successfully',
      data: {
        previewUrl: previewUrl,
        filename: previewFilename
      }
    });
    
  } catch (error) {
    console.error('❌ Preview generation error:', error);
    
    // Clean up uploaded file
    if (req.file) {
      try {
        await imageProcessor.deleteFile(req.file.path);
      } catch {}
    }
    
    res.status(500).json({
      success: false,
      message: 'Failed to generate preview',
      error: error.message
    });
  }
});

module.exports = router;
