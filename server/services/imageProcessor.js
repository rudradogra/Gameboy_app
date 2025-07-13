const sharp = require('sharp');
const path = require('path');
const fs = require('fs').promises;
const { supabase, supabaseAdmin } = require('../config/supabase');

class ImageProcessor {
  constructor() {
    this.bucketName = 'profile-images';
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

  async uploadToSupabase(buffer, filename, contentType = 'image/png') {
    try {
      console.log(`📤 Uploading ${filename} to Supabase storage...`);
      console.log(`📊 Buffer size: ${buffer.length} bytes`);
      console.log(`🏷️ Content type: ${contentType}`);
      
      const { data, error } = await supabaseAdmin.storage
        .from(this.bucketName)
        .upload(filename, buffer, {
          contentType,
          upsert: true // Allow overwriting existing files
        });

      if (error) {
        console.error('❌ Supabase upload error:', error);
        throw new Error(`Failed to upload to Supabase: ${error.message}`);
      }

      console.log(`✅ Successfully uploaded to Supabase: ${filename}`);
      console.log(`📁 Upload data:`, data);
      
      // Verify the file was uploaded by checking if it exists
      const fileExists = await this.verifySupabaseFile(filename);
      if (!fileExists) {
        console.error('❌ File not found after upload!');
        throw new Error('File upload verification failed');
      }
      
      const publicUrl = this.getSupabaseImageUrl(filename);
      console.log(`🌐 Public URL: ${publicUrl}`);
      
      return data;
    } catch (error) {
      console.error('💥 Supabase upload exception:', error);
      throw error;
    }
  }

  getSupabaseImageUrl(filename) {
    const { data: { publicUrl } } = supabase.storage
      .from(this.bucketName)
      .getPublicUrl(filename);
    
    console.log(`🔗 Generated public URL for ${filename}: ${publicUrl}`);
    return publicUrl;
  }

  async verifySupabaseFile(filename) {
    try {
      console.log(`🔍 Verifying file exists in Supabase: ${filename}`);
      
      const { data, error } = await supabaseAdmin.storage
        .from(this.bucketName)
        .list('', {
          search: filename
        });

      if (error) {
        console.error('❌ Error checking file:', error);
        return false;
      }

      const fileExists = data && data.some(file => file.name === filename);
      console.log(`📄 File ${filename} exists: ${fileExists}`);
      return fileExists;
    } catch (error) {
      console.error('💥 Error verifying file:', error);
      return false;
    }
  }

  async convertToRetro8Bit(inputPath, outputFilename, size = 200) {
    try {
      console.log(`🎨 Processing balanced 8-bit pixel art: ${outputFilename}`);
      
      // Step 1: Use a more moderate pixel size for balanced effect
      const pixelSize = 48; // Increased from 32 for less extreme pixelation
      
      // Step 2: Create the 8-bit color palette (RGB values)
      const palette = [
        [0, 0, 0],       // Black
        [255, 255, 255], // White  
        [255, 0, 0],     // Red
        [0, 255, 0],     // Green
        [0, 0, 255],     // Blue
        [255, 255, 0],   // Yellow
        [0, 255, 255],   // Cyan
        [255, 0, 255]    // Magenta
      ];
      
      // Step 3: Process the image with moderate 8-bit effect
      const processedBuffer = await sharp(inputPath)
        // Resize to moderate resolution for balanced pixels
        .resize(pixelSize, pixelSize, { 
          kernel: 'nearest',
          fit: 'cover',
          position: 'center'
        })
        // Moderate saturation boost for retro feel without overdoing it
        .modulate({
          saturation: 1.6, // Reduced from 2.0
          brightness: 1.05 // Reduced from 1.1
        })
        // Apply the 8-color palette
        .png({
          palette: true,
          colors: 8,           // Exactly 8 colors as specified
          dither: 0,           // No dithering for clean pixel boundaries
          compressionLevel: 0, // No compression
          effort: 10           // Maximum effort for color quantization
        })
        .toBuffer();
      
      // Step 4: Take the pixelated result and upscale using nearest-neighbor
      const finalBuffer = await sharp(processedBuffer)
        .resize(size, size, { 
          kernel: 'nearest',  // Crucial: maintains blocky pixels
          fit: 'fill'         // Don't change aspect ratio
        })
        .png({
          compressionLevel: 0,
          adaptiveFiltering: false // Prevent smoothing
        })
        .toBuffer();

      // Upload to Supabase storage
      await this.uploadToSupabase(finalBuffer, outputFilename, 'image/png');
      
      console.log(`✅ Authentic 8-bit pixel art processed and uploaded: ${outputFilename}`);
      return this.getSupabaseImageUrl(outputFilename);
    } catch (error) {
      console.error('❌ Error processing 8-bit pixel art:', error);
      throw new Error(`8-bit pixel art processing failed: ${error.message}`);
    }
  }

  async convertToGameBoyStyle(inputPath, outputFilename) {
    try {
      console.log(`🎮 Processing balanced GameBoy Color-style image: ${outputFilename}`);
      
      // GameBoy Color with moderate pixelation
      const pixelSize = 56; // Increased from 40 for less extreme effect
      
      const processedBuffer = await sharp(inputPath)
        .resize(pixelSize, pixelSize, { 
          kernel: 'nearest',
          fit: 'cover',
          position: 'center'
        })
        // Moderate color enhancement
        .modulate({
          saturation: 1.5, // Reduced from 1.8
          brightness: 1.1  // Reduced from 1.2
        })
        // Use 8-color palette like original spec
        .png({
          palette: true,
          colors: 8,
          dither: 0,
          compressionLevel: 0,
          effort: 10
        })
        .toBuffer();
      
      // Upscale to final size maintaining pixels
      const finalBuffer = await sharp(processedBuffer)
        .resize(160, 160, { 
          kernel: 'nearest',
          fit: 'fill'
        })
        .png({
          compressionLevel: 0,
          adaptiveFiltering: false
        })
        .toBuffer();

      // Upload to Supabase storage
      await this.uploadToSupabase(finalBuffer, outputFilename, 'image/png');
      
      console.log(`✅ GameBoy Color-style image processed and uploaded: ${outputFilename}`);
      return this.getSupabaseImageUrl(outputFilename);
    } catch (error) {
      console.error('❌ Error processing GameBoy Color-style image:', error);
      throw new Error(`GameBoy Color-style processing failed: ${error.message}`);
    }
  }

  async convertToRetroPixelated(inputPath, outputFilename) {
    try {
      console.log(`🕹️ Processing moderate retro pixel art: ${outputFilename}`);
      
      // Retro style with moderate pixelation
      const pixelSize = 36; // Increased from 24 for less extreme effect
      
      const processedBuffer = await sharp(inputPath)
        .resize(pixelSize, pixelSize, { 
          kernel: 'nearest',
          fit: 'cover',
          position: 'center'
        })
        // Moderate saturation for retro colors
        .modulate({
          saturation: 1.8, // Reduced from 2.2
          brightness: 1.08 // Reduced from 1.15
        })
        // Strict 8-color palette
        .png({
          palette: true,
          colors: 8,           // Exactly 8 basic colors
          dither: 0,           // No dithering for clean pixels
          compressionLevel: 0,
          effort: 10
        })
        .toBuffer();
      
      // Upscale to create large, chunky pixels
      const finalBuffer = await sharp(processedBuffer)
        .resize(200, 200, { 
          kernel: 'nearest',
          fit: 'fill'
        })
        .png({
          compressionLevel: 0,
          adaptiveFiltering: false
        })
        .toBuffer();

      // Upload to Supabase storage
      await this.uploadToSupabase(finalBuffer, outputFilename, 'image/png');
      
      console.log(`✅ NES-style 8-bit pixel art processed and uploaded: ${outputFilename}`);
      return this.getSupabaseImageUrl(outputFilename);
    } catch (error) {
      console.error('❌ Error processing NES-style pixel art:', error);
      throw new Error(`NES-style pixel art processing failed: ${error.message}`);
    }
  }

  // Alternative method for controlled pixelation
  async convertToExtremePixelArt(inputPath, outputFilename, pixelResolution = 24) {
    try {
      console.log(`🎯 Processing controlled pixel art (${pixelResolution}x${pixelResolution}): ${outputFilename}`);
      
      const processedBuffer = await sharp(inputPath)
        .resize(pixelResolution, pixelResolution, { 
          kernel: 'nearest',
          fit: 'cover',
          position: 'center'
        })
        // Balanced saturation for clean retro look
        .modulate({
          saturation: 2.0, // Reduced from 2.5
          brightness: 1.08 // Reduced from 1.1
        })
        // Force exactly 8 colors: Black, White, Red, Green, Blue, Yellow, Cyan, Magenta
        .png({
          palette: true,
          colors: 8,
          dither: 0,
          compressionLevel: 0,
          effort: 10
        })
        .toBuffer();
      
      // Upscale with nearest-neighbor to maintain crisp pixels
      const finalBuffer = await sharp(processedBuffer)
        .resize(200, 200, { 
          kernel: 'nearest',
          fit: 'fill'
        })
        .png({
          compressionLevel: 0,
          adaptiveFiltering: false
        })
        .toBuffer();

      await this.uploadToSupabase(finalBuffer, outputFilename, 'image/png');
      
      console.log(`✅ Extreme pixel art (${pixelResolution}x${pixelResolution}) processed: ${outputFilename}`);
      return this.getSupabaseImageUrl(outputFilename);
    } catch (error) {
      console.error('❌ Error processing extreme pixel art:', error);
      throw new Error(`Extreme pixel art processing failed: ${error.message}`);
    }
  }

  async deleteFile(filePath) {
    try {
      await fs.unlink(filePath);
      console.log(`🗑️ Deleted local file: ${filePath}`);
    } catch (error) {
      console.warn(`⚠️ Could not delete local file ${filePath}: ${error.message}`);
    }
  }

  async deleteFromSupabase(filename) {
    try {
      console.log(`🗑️ Deleting from Supabase: ${filename}`);
      
      const { error } = await supabaseAdmin.storage
        .from(this.bucketName)
        .remove([filename]);

      if (error) {
        console.error('❌ Supabase delete error:', error);
        throw new Error(`Failed to delete from Supabase: ${error.message}`);
      }

      console.log(`✅ Successfully deleted from Supabase: ${filename}`);
    } catch (error) {
      console.error('💥 Supabase delete exception:', error);
      throw error;
    }
  }

  getProcessedImageUrl(filename) {
    // Return Supabase public URL for cloud storage
    return this.getSupabaseImageUrl(filename);
  }
}

module.exports = new ImageProcessor();
