# Use a lightweight version of Node to build our app
FROM node:19 AS build

# Set the working directory in the Docker image
WORKDIR /app

# Copy package.json and package-lock.json for installing npm dependencies
COPY package.json package-lock.json ./

# Install npm dependencies
RUN npm install

# Copy the rest of the files from the host into the image
COPY . .

# Build the Svelte app
RUN npm run build

# Use Nginx to serve the Svelte app
FROM nginx:alpine

# Copy the build directory from the build image to the nginx image
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for the nginx server
EXPOSE 80

# Command to run the nginx server
CMD ["nginx", "-g", "daemon off;"]
