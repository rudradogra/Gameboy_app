# GameBoy Dating App - Backend Server

A Node.js backend server for the GameBoy Dating App with Supabase integration.

## 🚀 Features

- **Authentication**: JWT-based auth with registration, login, and token verification
- **User Management**: Complete user profile management
- **Dating Profiles**: Create, update, and discover dating profiles
- **Matching System**: Like, superlike, pass, and mutual matching
- **Image Upload**: Secure image upload to Supabase Storage
- **Security**: Rate limiting, CORS, helmet, input validation
- **Database**: Supabase PostgreSQL integration

## 📦 Installation

1. **Clone and navigate to the server directory:**
   ```bash
   cd server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   Copy the `.env` file and fill in your Supabase credentials:
   ```bash
   cp .env .env.local
   ```

4. **Configure your Supabase database** (see Database Schema section below)

5. **Start the server:**
   ```bash
   # Development mode with auto-reload
   npm run dev

   # Production mode
   npm start
   ```

## 🗄️ Database Schema

Create these tables in your Supabase database:

### Users Table
```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);
```

### Profiles Table
```sql
CREATE TABLE profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  age INTEGER NOT NULL CHECK (age >= 18 AND age <= 100),
  bio TEXT DEFAULT '',
  interests TEXT[] DEFAULT '{}',
  location VARCHAR(255) DEFAULT '',
  image_urls TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Matches Table
```sql
CREATE TABLE matches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user1_action VARCHAR(20) NOT NULL CHECK (user1_action IN ('like', 'superlike', 'pass')),
  user2_action VARCHAR(20) CHECK (user2_action IN ('like', 'superlike', 'pass')),
  is_mutual BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user1_id, user2_id)
);
```

### Storage Bucket
Create a storage bucket named `profile-images` in your Supabase dashboard with public access.

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/verify` - Verify JWT token

### User Management
- `GET /api/users/me` - Get current user profile
- `PUT /api/users/me` - Update user profile
- `DELETE /api/users/me` - Delete user account

### Dating Profiles
- `GET /api/profiles/discover` - Get profiles for discovery
- `GET /api/profiles/me` - Get current user's dating profile
- `POST /api/profiles/me` - Create/update dating profile
- `GET /api/profiles/:profileId` - Get specific profile
- `DELETE /api/profiles/me` - Deactivate profile

### Matching
- `POST /api/matches` - Create match (like/superlike/pass)
- `GET /api/matches/me` - Get all matches
- `GET /api/matches/mutual` - Get mutual matches only
- `DELETE /api/matches/:matchId` - Unmatch

### File Upload
- `POST /api/upload/image` - Upload single image
- `POST /api/upload/images` - Upload multiple images
- `DELETE /api/upload/image` - Delete image
- `GET /api/upload/images/me` - Get user's uploaded images

## 🔒 Security Features

- **Rate Limiting**: 100 requests per 15 minutes per IP
- **CORS**: Configurable allowed origins
- **Helmet**: Security headers
- **Input Validation**: Express-validator for all inputs
- **JWT Authentication**: Secure token-based auth
- **Password Hashing**: bcryptjs with 12 salt rounds
- **File Upload Security**: Type and size validation

## 🛠️ Environment Variables

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Supabase Configuration
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRES_IN=7d

# File Upload Configuration
MAX_FILE_SIZE=5242880
ALLOWED_FILE_TYPES=image/jpeg,image/png,image/jpg

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## 📱 Integration with Flutter App

The server is designed to work seamlessly with your Flutter GameBoy Dating App. Use these endpoints to:

1. **User Registration/Login**: Handle authentication
2. **Profile Management**: Create and update dating profiles
3. **Discovery**: Get profiles for the GameBoy card interface
4. **Matching**: Handle swipe actions (like/pass/superlike)
5. **Image Upload**: Upload profile pictures

## 🚀 Deployment

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

### Health Check
Visit `http://localhost:3000/health` to verify the server is running.

## 📝 License

MIT License - feel free to use this for your GameBoy Dating App!
