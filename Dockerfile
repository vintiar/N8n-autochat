FROM n8nio/n8n:latest

# Railway sets PORT env var, n8n uses N8N_PORT
ENV N8N_PORT=5678

EXPOSE 5678
