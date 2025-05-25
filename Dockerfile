FROM python:3.12-slim

WORKDIR /app

# Install system dependencies for Playwright
RUN apt-get update && apt-get install -y \
    wget \
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxcb1 \
    libxkbcommon0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY pyproject.toml uv.lock ./
RUN pip install --no-cache-dir uv && \
    uv pip install --system crawl4ai==0.6.2 mcp==1.7.1 supabase==2.15.1 openai==1.71.0 dotenv==0.9.9 playwright>=1.49.0

# Install Playwright and its browser
RUN playwright install chromium --with-deps

# Copy the application
COPY . .

# Install the application and run setup
RUN uv pip install --system -e . && \
    crawl4ai-setup

# Declare build arguments for required environment variables
ARG PORT=8051
ARG OPENAI_API_KEY
ARG OPENAI_API_BASE
ARG MODEL_CHOICE
ARG SUPABASE_URL
ARG SUPABASE_SERVICE_KEY

# Set environment variables
ENV PORT=${PORT}
ENV OPENAI_API_KEY=${OPENAI_API_KEY}
ENV OPENAI_API_BASE=${OPENAI_API_BASE}
ENV MODEL_CHOICE=${MODEL_CHOICE}
ENV SUPABASE_URL=${SUPABASE_URL}
ENV SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}

WORKDIR /app

# Expose the port
EXPOSE ${PORT}

# Command to run the MCP server directly with python
CMD ["python", "src/crawl4ai_mcp.py"]