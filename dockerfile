FROM python:3.12-alpine AS builder
WORKDIR /build
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
 && pip uninstall -y pip

FROM python:3.12-alpine
RUN apk upgrade --no-cache \
 && pip uninstall -y pip \
 && addgroup -S app \
 && adduser -S -G app -H -s /sbin/nologin app
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY . .
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
USER app
EXPOSE 4000
HEALTHCHECK CMD wget -qO- http://localhost:4000/ || exit 1
CMD ["python", "main.py"]
