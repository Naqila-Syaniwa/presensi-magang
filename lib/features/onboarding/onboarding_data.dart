class OnboardingData {
  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title; 
  final String description;
}

const List<OnboardingData> onboardingPages = [
  OnboardingData(
    image: 'assets/images/onboarding-1.svg',
    title: 'Welcome to Talenta',
    description: 'Easier access to manage your HR administration needs.',
  ),
  OnboardingData(
    image: 'assets/images/onboarding-2.svg',
    title: 'Get things done anywhere, anytime',
    description: 'You can do the attendance, request time off, reimbursement, and other related matters.',
  ),
  OnboardingData(
    image: 'assets/images/onboarding-3.svg',
    title: 'Always keep updated with office info',
    description: 'Make sure notifications are active so you don\'t miss important info from your company.',
  ),
];