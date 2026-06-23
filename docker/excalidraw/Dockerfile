FROM alswl/excalidraw-storage-backend:v2023.11.11

USER root
RUN sed -i 's/stream\.push(data);/if (typeof data === "object" \&\& data.data) { stream.push(Buffer.from(data.data)); } else if (Buffer.isBuffer(data)) { stream.push(data); } else { stream.push(JSON.stringify(data)); }/' /app/dist/scenes/scenes.controller.js
USER node
