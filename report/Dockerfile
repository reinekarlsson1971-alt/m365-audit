# Dockerfile
# Builds a container that runs the report scripts. Linux inside, regardless of host OS.

FROM python:3.12-slim
# Start from an official image: Debian Linux with Python 3.12 preinstalled. "slim" = minimal.

WORKDIR /app
# All following commands run inside /app in the container. Like "cd /app".

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Copy only requirements first, then install. Docker caches this layer:
# if requirements.txt is unchanged, the install step is skipped on the next build.

COPY *.py .
# Copy the scripts. Done after pip install so code changes don't trigger a reinstall.

CMD ["python", "build_report.py"]
# Default command when the container starts. Can be overridden at run time.