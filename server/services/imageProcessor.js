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

  async convertToGameBoyStyle(inputPath, outputFilename) {
    await this.ensureDirectoryExists(this.outputDir);
    
    const outputPath = path.join(this.outputDir, outputFilename);
    
    try {
      // GameBoy-style processing: resize, pixelate, and apply GameBoy color palette
      await sharp(inputPath)
        .resize(160, 144, { 
          fit: 'cover',
          position: 'center'
        })
        // Convert to grayscale first for authentic GameBoy feel
        .grayscale()
        // Reduce to 4 colors (GameBoy had 4 shades of green)
        .png({
          palette: true,
          colors: 4,
          dither: 1.0
        })
        // Apply pixelated effect by scaling down and back up
        .resize(80, 72, { kernel: 'nearest' })
        .resize(160, 144, { kernel: 'nearest' })
        .toFile(outputPath);

      console.log(`✅ Image processed successfully: ${outputFilename}`);
      return outputPath;
    } catch (error) {
      console.error('❌ Error processing image:', error);
      throw new Error(`Image processing failed: ${error.message}`);
    }
  }

  async convertToRetroPixelated(inputPath, outputFilename) {
    await this.ensureDirectoryExists(this.outputDir);
    
    const outputPath = path.join(this.outputDir, outputFilename);
    
    try {
      // Create retro pixelated effect with limited color palette
      await sharp(inputPath)
        .resize(200, 200, { 
          fit: 'cover',
          position: 'center'
        })
        // First, reduce colors to create that retro look
        .png({
          palette: true,
          colors: 16, // Limited color palette
          dither: 0.5
        })
        // Create pixelated effect
        .resize(50, 50, { kernel: 'nearest' }) // Scale down with nearest neighbor
        .resize(200, 200, { kernel: 'nearest' }) // Scale back up to maintain pixels
        .toFile(outputPath);

      console.log(`✅ Retro image processed successfully: ${outputFilename}`);
      return outputPath;
    } catch (error) {
      console.error('❌ Error processing retro image:', error);
      throw new Error(`Retro image processing failed: ${error.message}`);
    }
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
