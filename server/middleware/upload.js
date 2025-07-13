const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

// Ensure upload directories exist
const uploadDir = path.join(__dirname, '../uploads/images');
const processedDir = path.join(__dirname, '../uploads/processed');

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log('📁 Created uploads/images directory');
}

if (!fs.existsSync(processedDir)) {
  fs.mkdirSync(processedDir, { recursive: true });
  console.log('📁 Created uploads/processed directory');
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename with original extension
    const uniqueName = uuidv4() + path.extname(file.originalname);
    cb(null, uniqueName);
  }
});

// File filter to only allow images
const fileFilter = (req, file, cb) => {
  console.log('🔍 File filter check:');
  console.log('📁 Original name:', file.originalname);
  console.log('🏷️ Mimetype:', file.mimetype);
  console.log('📝 Field name:', file.fieldname);
  
  // Check by file extension as fallback
  const fileExt = file.originalname.toLowerCase().split('.').pop();
  console.log('📎 File extension:', fileExt);
  
  const allowedMimes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif',
    'image/webp',
    'image/heic',
    'image/heif'
  ];
  
  const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'];
  
  // Check both mimetype and file extension
  const mimeAllowed = allowedMimes.includes(file.mimetype.toLowerCase());
  const extAllowed = allowedExtensions.includes(fileExt);
  
  if (mimeAllowed || extAllowed) {
    console.log('✅ File type accepted:', file.mimetype, 'Extension:', fileExt);
    cb(null, true);
  } else {
    console.log('❌ File type rejected:', file.mimetype, 'Extension:', fileExt);
    console.log('📋 Allowed mimetypes:', allowedMimes);
    console.log('📋 Allowed extensions:', allowedExtensions);
    cb(new Error('Invalid file type. Only JPEG, PNG, GIF, WebP, and HEIC are allowed.'), false);
  }
};

// Configure multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
    files: 3 // Maximum 3 files per upload
  }
});

module.exports = upload;
