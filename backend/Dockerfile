FROM node:20

# Set working directory
WORKDIR /app

# Copy package.json first for caching
COPY package*.json ./

# Install production dependencies
RUN npm install --production

# Copy rest of the code
COPY . .

# Expose the backend port
EXPOSE 8080

# Run backend
CMD ["node", "server.js"]

