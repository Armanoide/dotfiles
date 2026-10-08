FROM node:18-alpine

# rsync_dashboard — parser (cron) + serveur web a onglets
WORKDIR /app

COPY rsync_dashboard.js /app/rsync_dashboard.js
COPY server.js /app/server.js

# cron interne: parse+render a H+5 (apres le rsync de H+0)
RUN echo '5 * * * * cd /app && node rsync_dashboard.js --incremental --render >> /dashboard/cron.log 2>&1' > /etc/crontabs/root \
    && chmod 0644 /etc/crontabs/root

EXPOSE 8090

# backfill au boot, puis crond (background) + serveur web (foreground PID1)
CMD ["sh", "-c", "node rsync_dashboard.js --backfill --render && crond -b -l 8 && exec node server.js"]
