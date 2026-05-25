#!/usr/bin/env sh


# Initialize Waypoint
waypoint init

# Build, deploy, and release (runs the container locally)
waypoint up

# Get the URL for the running service
waypoint url
