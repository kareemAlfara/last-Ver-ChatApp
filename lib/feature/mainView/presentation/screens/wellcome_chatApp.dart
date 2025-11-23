import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/repositoryImpl/authRepoImpl.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/getAllusersusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/loginusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/logoutUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/logincubit/login_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/screens/friends.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(

        loginusecase: Loginusecase(repositiry: Authrepoimpl.init()),
        logoutusecase: Logoutusecase(authRepo: Authrepoimpl.init()),
              getallusersusecase: Getallusersusecase(
                authRepository: Authrepoimpl.init(),
              ),
      ),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Scaffold(
            // backgroundColor: const Color(0xFFF5F5F5),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Decorative background pattern
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black45,
                        ),
                        child: Stack(
                          children: [
                            // Background pattern (simplified)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: BackgroundPatternPainter(),
                              ),
                            ),
                            // Profile circles grid
                            Center(
                              child: Container(
                                width: 280,
                                height: 280,
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildProfileCircle(
                                      'https://images.unsplash.com/photo-1575936123452-b67c3203c357?q=80&w=200&h=200&fit=crop&crop=face&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                      const Color(0xFF6C5CE7),
                                    ),
                                    _buildProfileCircle(
                                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                                      const Color(0xFF6C5CE7),
                                    ),
                                    _buildProfileCircle(
                                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
                                      const Color(0xFF6C5CE7),
                                    ),
                                    _buildProfileCircle(
                                      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face',
                                      const Color(0xFF6C5CE7),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title and subtitle
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text(
                            'Enjoy the new experience of\nchatting with global friends .',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Connect people around the world for free',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),

                          // Get Started button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C5CE7), Color(0xFF8B7ED8)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6C5CE7,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendsScreen(),
                                  ),
                                );
                                // Handle get started action
                                print('Get Started pressed');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCircle(String imageUrl, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey[300],
          backgroundImage: NetworkImage(imageUrl),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback to icon if image fails to load
          },
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw some decorative lines and shapes
    final path = Path();

    // Chat bubble shapes
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 12, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.8), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7), 14, paint);

    // Curved lines
    path.moveTo(size.width * 0.2, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.05,
      size.width * 0.6,
      size.height * 0.15,
    );
    canvas.drawPath(path, paint);

    // More decorative elements can be added here
    final rectPaint = Paint()
      ..color = Colors.grey.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.4, 40, 20),
        const Radius.circular(10),
      ),
      rectPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
