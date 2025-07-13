const sharp = require('sharp');
const path = require('path');
const fs = require('fs').promises;

class ImageProcessor {
  constructor() {
    this.outputDir = path.join(__dirname, '../uploads/processed');
    this.inputDir = path.join(__dirname, '../uploads/images');
  }

  async ensureDirectoryExists(dirPath) {
    try {
      await fs.access(dirPath);
    } catch {
      await fs.mkdir(dirPath, { recursive: true });
    }
  }

  async convertToRetro8Bit(inputPath, outputFilename, size = 200) {
    await this.ensureDirectoryExists(this.outputDir);
    
    const outputPath = path.join(this.outputDir, outputFilename);
    
    try {
      // Create authentic 8-bit retro effect with enhanced pixelation and vibrant colors
      const pipeline = sharp(inputPath)
        .resize(size, size, { 
          fit: 'cover',
          position: 'center'
        });

      // Apply color enhancement and pixelation
      await pipeline
        // Enhance saturation for more vibrant RGB colors
        .modulate({
          saturation: 1.8, // Boost saturation for vivid retro colors
          brightness: 1.1  // Slight brightness increase
        })
        // Create heavy pixelation effect
        .resize(16, 16, { kernel: 'nearest' }) // Very small for chunky pixels
        .resize(size, size, { kernel: 'nearest' }) // Scale back up maintaining pixel blocks
        // Apply limited color palette for authentic retro look
        .png({
          palette: true,
          colors: 32, // Increased from 16 for better color variety but still retro
          dither: 0.3, // Reduced dither for cleaner pixel blocks
          compressionLevel: 0 // No compression to maintain sharp pixels
        })
        .toFile(outputPath);

      console.log(`✅ 8-bit retro image processed successfully: ${outputFilename}`);
      return outputPath;
    } catch (error) {
      console.error('❌ Error processing 8-bit retro image:', error);
      throw new Error(`8-bit retro processing failed: ${error.message}`);
    }
  }

  async convertToGameBoyStyle(inputPath, outputFilename) {
    // Use the same 8-bit processing for consistency
    return this.convertToRetro8Bit(inputPath, outputFilename, 160);
  }

  async convertToRetroPixelated(inputPath, outputFilename) {
    // Use the same 8-bit processing for consistency
    return this.convertToRetro8Bit(inputPath, outputFilename, 200);
  }

  async deleteFile(filePath) {
    try {
      await fs.unlink(filePath);
      console.log(`🗑️ Deleted file: ${filePath}`);
    } catch (error) {
      console.warn(`⚠️ Could not delete file ${filePath}: ${error.message}`);
    }
  }

  getProcessedImageUrl(filename) {
    // Return full URL that will pass backend validation
    const baseUrl = process.env.NODE_ENV === 'production' 
      ? process.env.BASE_URL || 'https://your-domain.com'
      : 'http://localhost:3000';
    return `${baseUrl}/api/images/${filename}`;
  }
}

module.exports = new ImageProcessor();
