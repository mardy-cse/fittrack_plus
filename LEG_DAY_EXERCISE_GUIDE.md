# Leg Day Exercise Guide Setup

## Overview
This document describes how the Leg Day Intensity workout has been configured with visual exercise demonstrations using GIFs and webP images.

## Files Added

### Exercise Media Files
The following exercise demonstration files have been added to `assets/images/exercises/`:

1. **Squats** - `squats.gif` (257 KB)
2. **Lunges** - `lunges.gif` (160 KB)  
3. **Leg Press** - `leg_press.gif` (187 KB)
4. **Hamstring Curls** - `hamstring_curls.webp` (447 KB)
5. **Calf Raises** - `calf_raises.webp` (19 KB)

## Implementation Details

### 1. Asset Configuration
Updated `pubspec.yaml` to include the exercises folder:
```yaml
assets:
  - assets/images/exercises/
```

### 2. Exercise Animation Mapping
Added mappings in [workout_detail_view.dart](lib/app/views/workout/workout_detail_view.dart) (`_getAnimationForExercise` method):

```dart
// Leg Day exercises - check these before generic matches
if (name.contains('squat') && !name.contains('jump')) {
  return 'assets/images/exercises/squats.gif';
}
if (name.contains('lunge')) {
  return 'assets/images/exercises/lunges.gif';
}
if (name.contains('leg') && name.contains('press')) {
  return 'assets/images/exercises/leg_press.gif';
}
if (name.contains('hamstring') && name.contains('curl')) {
  return 'assets/images/exercises/hamstring_curls.webp';
}
if (name.contains('calf') && name.contains('raise')) {
  return 'assets/images/exercises/calf_raises.webp';
}
```

### 3. Workout Data Update
Updated [sample_workouts.json](assets/data/sample_workouts.json):
- Changed `animationAsset` to use the squats GIF as the main workout animation
- Enhanced workout description with form guidance

## How It Works

### Exercise Display System
1. **Workout Overview**: The main workout card shows the primary animation (squats.gif)
2. **Exercise List**: Each exercise in the "Exercises" section can be expanded
3. **Individual Animations**: When expanded, each exercise shows its specific demonstration GIF/webP
4. **Smart Matching**: The system automatically matches exercise names to their animations

### Supported Formats
The `_buildAnimationWidget` function supports:
- `.gif` - Animated GIF files
- `.webp` - WebP images (static or animated)
- `.png`, `.jpg`, `.jpeg` - Static images
- `.json`, `.lottie` - Lottie animations

## Adding New Exercise Demonstrations

To add more exercise GIFs/images:

### Step 1: Add Media Files
Copy your exercise demonstration files to `assets/images/exercises/`

### Step 2: Update Animation Mapping
Add mapping in `_getAnimationForExercise` function:
```dart
if (name.contains('exercise_name')) {
  debugPrint('✅ Matched Exercise Name -> filename.gif');
  return 'assets/images/exercises/filename.gif';
}
```

### Step 3: Test
Run the app and navigate to the workout detail page to verify the animations display correctly.

## Best Practices

### File Naming
- Use lowercase with underscores: `leg_press.gif`
- Make names descriptive and searchable
- Avoid spaces in filenames

### File Size
- Keep GIFs under 500 KB when possible
- Optimize webP images for mobile
- Use appropriate dimensions (recommended: 280x280 to 400x400 pixels)

### Animation Quality
- Ensure smooth looping
- Show proper form and full movement range
- Use clear, well-lit demonstrations
- Trim unnecessary frames

## Leg Day Workout Details

**Workout ID**: `workout_7`  
**Title**: Leg Day Intensity  
**Level**: Intermediate  
**Duration**: ~4 minutes (260 seconds)  
**Calories**: 320  
**Category**: Strength

### Exercises
1. **Squats** - Compound lower body exercise targeting quads, glutes, and hamstrings
2. **Lunges** - Unilateral leg exercise for balance and strength
3. **Leg Press** - Machine-based compound movement for max leg development
4. **Hamstring Curls** - Isolation exercise for hamstring strength
5. **Calf Raises** - Targeted calf muscle development

## User Experience

### How Users See It
1. User opens "Leg Day Intensity" workout
2. Main workout animation shows squats demonstration
3. User scrolls to "Exercises" section
4. Each exercise has a number and name
5. Tapping an exercise expands it to show:
   - Exercise-specific GIF/webP demonstration
   - Visual guidance for proper form
   - Auto-looping animation

### Tips for Users
- Watch the full animation before starting
- Focus on matching the form shown
- Use the pause button if needed during workout
- Refer back to animations between sets

## Technical Notes

### Animation Widget
The `_buildAnimationWidget` handles both:
- **Image formats** (GIF, webP, PNG, JPG) - Displayed with `Image.asset()`
- **Lottie animations** (JSON) - Displayed with `Lottie.asset()`

### Error Handling
If an animation file is missing or fails to load:
- A fallback icon is displayed (fitness dumbbell icon)
- "Ready to workout!" message shows
- App continues to function normally

## Future Enhancements

Potential improvements:
- [ ] Add exercise instructions text below animations
- [ ] Include rep counts and set recommendations
- [ ] Add difficulty variations for each exercise
- [ ] Create exercise library screen
- [ ] Allow users to favorite exercises
- [ ] Add video demonstrations for premium users

## Maintenance

### Updating Exercise Media
To replace an exercise GIF:
1. Keep the same filename
2. Replace the file in `assets/images/exercises/`
3. Run `flutter pub get`
4. Hot reload or restart the app

### Adding New Workouts
When creating new workouts with custom exercises:
1. Add exercise GIFs to `assets/images/exercises/`
2. Update `_getAnimationForExercise` mappings
3. Reference exercises by name in workout JSON
4. Test on multiple devices/screen sizes

## Related Documentation
- [WORKOUT_ANIMATION_GUIDE.md](WORKOUT_ANIMATION_GUIDE.md) - General animation system
- [FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md) - Project organization
- [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md) - Full app documentation

---

**Last Updated**: February 19, 2026  
**Status**: ✅ Complete and Tested
