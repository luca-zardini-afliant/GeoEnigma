#!/usr/bin/env python3
"""
Simple script to create placeholder flag images for testing
"""
from PIL import Image, ImageDraw
import os

# Create flags directory if it doesn't exist
os.makedirs('assets/flags', exist_ok=True)

# Flag colors (simplified)
flags = {
    'france.png': [(0, 0, 139), (255, 255, 255), (220, 20, 60)],  # Blue, White, Red
    'monaco.png': [(220, 20, 60), (255, 255, 255)],  # Red, White
    'brazil.png': [(0, 100, 0), (255, 215, 0)],  # Green, Gold
    'canada.png': [(255, 0, 0), (255, 255, 255)],  # Red, White
    'australia.png': [(0, 0, 139), (255, 255, 255)],  # Blue, White
    'turkey.png': [(220, 20, 60), (255, 255, 255)],  # Red, White
    'uae.png': [(0, 100, 0), (255, 255, 255), (0, 0, 0)],  # Green, White, Black
    'netherlands.png': [(220, 20, 60), (255, 255, 255), (0, 0, 139)],  # Red, White, Blue
}

def create_flag(filename, colors):
    # Create a 90x60 image (3:2 ratio)
    width, height = 90, 60
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    if len(colors) == 2:
        # Two colors - split vertically
        draw.rectangle([0, 0, width//2, height], fill=colors[0])
        draw.rectangle([width//2, 0, width, height], fill=colors[1])
    elif len(colors) == 3:
        # Three colors - split into thirds
        third = width // 3
        draw.rectangle([0, 0, third, height], fill=colors[0])
        draw.rectangle([third, 0, 2*third, height], fill=colors[1])
        draw.rectangle([2*third, 0, width, height], fill=colors[2])
    
    img.save(f'assets/flags/{filename}')
    print(f'Created {filename}')

# Create all flags
for filename, colors in flags.items():
    create_flag(filename, colors)

print('All flag images created!')
