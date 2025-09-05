#!/usr/bin/env python3
"""
Simple script to create colored flag placeholders for the GeoEnigma game.
This creates simple colored rectangles as flag placeholders.
"""

import os
from PIL import Image, ImageDraw

# Flag colors (simple representations)
flag_colors = {
    'france.png': [(0, 35, 149), (255, 255, 255), (237, 41, 57)],  # Blue, White, Red
    'monaco.png': [(207, 20, 43), (255, 255, 255)],  # Red, White
    'brazil.png': [(0, 156, 59), (255, 223, 0), (0, 39, 118)],  # Green, Yellow, Blue
    'canada.png': [(255, 0, 0), (255, 255, 255)],  # Red, White
    'australia.png': [(0, 0, 139), (255, 255, 255), (255, 0, 0)],  # Dark Blue, White, Red
    'turkey.png': [(227, 10, 23), (255, 255, 255)],  # Red, White
    'uae.png': [(0, 115, 47), (255, 255, 255), (0, 0, 0), (255, 0, 0)],  # Green, White, Black, Red
    'netherlands.png': [(174, 28, 40), (255, 255, 255), (33, 70, 139)],  # Red, White, Blue
}

def create_flag_image(flag_name, colors, width=120, height=80):
    """Create a simple flag image with the given colors."""
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    if len(colors) == 2:
        # Two colors - split horizontally
        draw.rectangle([0, 0, width, height//2], fill=colors[0])
        draw.rectangle([0, height//2, width, height], fill=colors[1])
    elif len(colors) == 3:
        # Three colors - split vertically
        draw.rectangle([0, 0, width//3, height], fill=colors[0])
        draw.rectangle([width//3, 0, 2*width//3, height], fill=colors[1])
        draw.rectangle([2*width//3, 0, width, height], fill=colors[2])
    elif len(colors) == 4:
        # Four colors - 2x2 grid
        draw.rectangle([0, 0, width//2, height//2], fill=colors[0])
        draw.rectangle([width//2, 0, width, height//2], fill=colors[1])
        draw.rectangle([0, height//2, width//2, height], fill=colors[2])
        draw.rectangle([width//2, height//2, width, height], fill=colors[3])
    
    return img

def main():
    """Create all flag images."""
    flags_dir = 'assets/flags'
    
    # Create directory if it doesn't exist
    os.makedirs(flags_dir, exist_ok=True)
    
    for flag_name, colors in flag_colors.items():
        print(f"Creating {flag_name}...")
        img = create_flag_image(flag_name, colors)
        img.save(os.path.join(flags_dir, flag_name))
        print(f"✓ Created {flag_name}")
    
    print(f"\n✅ Created {len(flag_colors)} flag images in {flags_dir}/")

if __name__ == "__main__":
    main()
