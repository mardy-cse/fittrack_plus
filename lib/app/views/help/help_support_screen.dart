import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Section
          _buildWelcomeSection(context),
          const SizedBox(height: 24),

          // App Features Guide
          _buildAppFeaturesSection(context),
          const SizedBox(height: 32),

          // FAQ Section
          _buildFAQSection(context),
          const SizedBox(height: 32),

          // Contact Support
          _buildContactSection(context),
          const SizedBox(height: 32),

          // App Information
          _buildAppInfoSection(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50C878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to FitTrack Plus!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your comprehensive fitness companion',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'This guide will help you master all features and get the most out of your fitness journey. From workout tracking to AI coaching, everything is explained here.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAppFeaturesSection(BuildContext context) {
    final features = [
      FeatureGuide(
        title: '🏠 Home Tab',
        subtitle: 'Your fitness dashboard',
        description:
            '''
**Main Features:**
• Daily workout recommendations with AI suggestions
• Quick access to different workout types
• Level-based filtering (Beginner, Intermediate, Advanced)
• Current streak and motivation messages

**How to Use:**
1. Open app to see Home tab
2. Browse available workouts by category
3. Filter by your fitness level
4. Tap any workout to see details
5. Check AI suggestions at the top for personalized recommendations

**Pro Tips:**
• Swipe down to refresh workout suggestions
• Use the hamburger menu for quick access to AI Coach
• Your current streak is displayed for motivation
        '''
                .trim(),
        icon: Icons.home,
        color: const Color(0xFF4A90E2),
      ),

      FeatureGuide(
        title: '👤 Profile Management',
        subtitle: 'Customize your fitness profile',
        description:
            '''
**Profile Features:**
• Personal information (name, age, height, weight)
• Fitness level selection
• Profile and cover photo upload
• Daily goals setting (workouts, water, steps)
• Health metrics tracking

**How to Setup:**
1. Go to Profile tab
2. Tap Edit button (pencil icon)
3. Fill in your personal details
4. Set realistic daily goals
5. Upload profile photo from gallery or camera
6. Save changes

**Important Settings:**
• Set accurate height/weight for calorie calculations
• Choose appropriate fitness level for workout recommendations
• Set achievable daily goals to build consistency
        '''
                .trim(),
        icon: Icons.person,
        color: const Color(0xFF50C878),
      ),

      FeatureGuide(
        title: '🏋️‍♂️ Workout System',
        subtitle: 'Complete exercise tracking',
        description:
            '''
**Workout Features:**
• 25+ different workout types
• Detailed exercise instructions and animations
• Built-in timer with rest periods
• Calorie tracking and duration monitoring
• Progress saving and history

**Starting a Workout:**
1. Choose workout from Home or Workouts tab
2. Read instructions and watch animations
3. Tap "Start Workout" button
4. Follow timer for each exercise
5. Take rest breaks as prompted
6. Complete and save your session

**Exercise Types Available:**
• **Cardio:** Running, Jumping Jacks, High Knees
• **Strength:** Push-ups, Squats, Planks, Sit-ups
• **Flexibility:** Yoga poses, Stretching routines
• **HIIT:** High-intensity interval training
        '''
                .trim(),
        icon: Icons.fitness_center,
        color: Colors.orange,
      ),

      FeatureGuide(
        title: '📈 Progress Tracking',
        subtitle: 'Monitor your fitness journey',
        description:
            '''
**Progress Analytics:**
• Workout history with detailed stats
• Streak tracking and achievements
• Calorie burn charts and trends
• Performance improvements over time
• Weekly/monthly summaries

**Available Metrics:**
• Total workouts completed
• Current streak (consecutive days)
• Calories burned per session and total
• Average workout duration
• Exercise type preferences
• Performance trends

**How to View Progress:**
1. Go to Progress tab
2. Browse your workout history
3. Check streak counter and achievements
4. View detailed charts and statistics
5. Export data for external analysis

**Achievement System:**
🥇 Workout milestones (5, 10, 25, 50+ sessions)
🔥 Streak achievements (3, 7, 14, 30+ days)
⚡ Calorie burn targets
🏆 Monthly challenges completion
        '''
                .trim(),
        icon: Icons.trending_up,
        color: Colors.green,
      ),

      FeatureGuide(
        title: '🛠️ Tools Section',
        subtitle: 'Additional fitness tools',
        description:
            '''
**Water Tracker:**
• Daily hydration goal (8 glasses default)
• Quick glass logging with timestamps
• Progress visualization with circular indicator
• Historical tracking and streaks
• Reminder notifications (future feature)

**How to Track Water:**
1. Go to Tools tab
2. Open Water Tracker
3. Tap "+" to log glasses consumed
4. View daily progress percentage
5. Check history for consistency

**BMI Calculator:**
• Calculate Body Mass Index
• Health category classification
• Recommendations based on results
• Track changes over time

**Step Counter:**
• Daily step tracking (on real devices)
• Goal setting and progress monitoring
• Weekly averages and trends
• Integration with device sensors

**Additional Tools:**
• Workout planner for custom routines
• Nutrition calculator (coming soon)
• Heart rate monitoring integration
        '''
                .trim(),
        icon: Icons.build,
        color: Colors.purple,
      ),

      FeatureGuide(
        title: '🤖 AI Fitness Coach',
        subtitle: 'Your personal trainer',
        description:
            '''
**FitBot Capabilities:**
• Personalized workout recommendations
• Real-time fitness advice and motivation
• Progress analysis and insights
• Nutrition guidance and meal suggestions
• Injury prevention tips
• Goal setting assistance

**How to Chat with FitBot:**
1. Access through drawer menu or direct link
2. Ask questions about fitness, nutrition, or health
3. Request workout suggestions based on your level
4. Get motivation when feeling demotivated
5. Seek advice on exercise form and techniques

**Question Examples:**
• "What exercises should I do today?"
• "How many calories did I burn this week?"
• "I'm feeling tired, should I work out?"
• "What's the best pre-workout meal?"
• "How can I improve my squat form?"
• "Create a workout plan for beginners"

**FitBot Features:**
• Access to your complete fitness data
• Contextual responses based on your progress
• Motivational coaching style
• Evidence-based fitness advice
• 24/7 availability for instant help

**Pro Tips for Better Responses:**
• Ask specific questions about your goals
• Mention your current fitness level
• Provide context about any limitations
• Ask for step-by-step instructions when needed
        '''
                .trim(),
        icon: Icons.smart_toy_rounded,
        color: Colors.indigo,
      ),

      FeatureGuide(
        title: '🔔 Smart Notifications',
        subtitle: 'Stay motivated and consistent',
        description:
            '''
**Proactive AI Suggestions:**
• Morning motivation messages
• Optimal workout timing recommendations
• Hydration reminders throughout the day
• Progress milestone celebrations
• Weekly performance summaries

**Notification Types:**
• **Morning Boost:** Personalized motivation at 8 AM
• **Workout Time:** Smart reminders based on your patterns
• **Hydration Alerts:** Water intake reminders every 3 hours
• **Streak Alerts:** Congratulations on reaching milestones
• **Weekly Reports:** Sunday evening progress summaries

**Customization:**
• Enable/disable specific notification types
• Set preferred reminder times
• Choose notification frequency
• Customize motivational message tone

**How Notifications Work:**
1. AI analyzes your activity patterns
2. Identifies optimal reminder times
3. Creates personalized motivational content
4. Sends contextual suggestions
5. Adapts based on your response patterns
        '''
                .trim(),
        icon: Icons.notifications_active,
        color: Colors.amber,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Complete App Guide', Icons.library_books),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureGuide(feature)),
      ],
    );
  }

  Widget _buildFeatureGuide(FeatureGuide feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: feature.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(feature.icon, color: feature.color, size: 24),
        ),
        title: Text(
          feature.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          feature.subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: _buildMarkdownText(feature.description),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownText(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF4A90E2),
              ),
            ),
          );
        } else if (line.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        } else if (line.trim().isEmpty) {
          return const SizedBox(height: 8);
        } else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line, style: const TextStyle(fontSize: 14, height: 1.4)),
        );
      }).toList(),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      FAQ(
        'How do I track my first workout?',
        'Go to Home tab → Choose any workout → Tap "Start Workout" → Follow the timer → Complete and save your session.',
      ),
      FAQ(
        'Why is my AI coach not responding?',
        'Check your internet connection and try again. FitBot requires internet to provide personalized responses.',
      ),
      FAQ(
        'How do I change my fitness level?',
        'Go to Profile tab → Tap Edit → Select your current fitness level → Save changes. This will update workout recommendations.',
      ),
      FAQ(
        'Can I export my progress data?',
        'Currently, you can view all progress within the app. Data export feature is coming in a future update.',
      ),
      FAQ(
        'How accurate is the calorie counting?',
        'Calorie estimates are based on your profile data and exercise intensity. Results may vary based on individual metabolism.',
      ),
      FAQ(
        'How do I reset my progress?',
        'Contact support for data reset requests. This action cannot be undone, so we require manual verification.',
      ),
      FAQ(
        'Is my data secure and private?',
        'Yes! All data is encrypted and stored securely. We never share personal information with third parties.',
      ),
      FAQ(
        'How often should I work out?',
        'Start with 3-4 sessions per week. Your AI coach will provide personalized recommendations based on your progress.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Frequently Asked Questions', Icons.help),
        const SizedBox(height: 16),
        ...faqs.map((faq) => _buildFAQTile(faq)),
      ],
    );
  }

  Widget _buildFAQTile(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(faq.answer, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Need More Help?', Icons.support_agent),
        const SizedBox(height: 16),
        _buildContactCard(
          'Email Support',
          'Get detailed help via email',
          Icons.email,
          'support@fittrackplus.com',
          () => _launchEmail(),
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          'Report Bug',
          'Found an issue? Let us know',
          Icons.bug_report,
          'Report technical problems',
          () => _showBugReportDialog(context),
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          'Feature Request',
          'Suggest new features',
          Icons.lightbulb_outline,
          'Share your ideas with us',
          () => _showFeatureRequestDialog(context),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    String title,
    String subtitle,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF4A90E2)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('App Information', Icons.info),
        const SizedBox(height: 16),
        _buildInfoTile('Version', '1.0.0'),
        _buildInfoTile('Developer', 'FitTrack Team'),
        _buildInfoTile('Release Date', 'February 2026'),
        _buildInfoTile('Platform', 'Android & iOS'),
        _buildInfoTile('Requirements', 'Android 6.0+ / iOS 12.0+'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _rateApp(),
                icon: const Icon(Icons.star),
                label: const Text('Rate App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareApp(),
                icon: const Icon(Icons.share),
                label: const Text('Share App'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4A90E2), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
          ),
        ),
      ],
    );
  }

  // Action methods
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@fittrackplus.com',
      query: 'subject=FitTrack Plus Support&body=Describe your issue here...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Email Not Available',
        'Please email us at: support@fittrackplus.com',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showBugReportDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Report Bug'),
        content: const Text(
          'To report a bug, please email us at support@fittrackplus.com with:\n\n'
          '• Description of the issue\n'
          '• Steps to reproduce\n'
          '• Your device model\n'
          '• App version (1.0.0)',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          TextButton(
            onPressed: () {
              Get.back();
              _launchEmail();
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Feature Request'),
        content: const Text(
          'We love hearing your ideas! Please email us at support@fittrackplus.com with:\n\n'
          '• Detailed feature description\n'
          '• How it would help you\n'
          '• Any mockups or examples\n'
          '• Your use case scenarios',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          TextButton(
            onPressed: () {
              Get.back();
              _launchEmail();
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    Get.snackbar(
      'Rate FitTrack Plus',
      'Feature coming soon! App Store rating will be available.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareApp() {
    Get.snackbar(
      'Share FitTrack Plus',
      'Share feature coming soon! Tell friends about us!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

// Data models
class FeatureGuide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  FeatureGuide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class FAQ {
  final String question;
  final String answer;

  FAQ(this.question, this.answer);
}
