import 'package:flutter/material.dart';

class RecentLessonWidget extends StatelessWidget {
  final String title;
  final bool showTitle;

  const RecentLessonWidget({
    super.key,
    this.showTitle = false,
    this.title = 'To Do:',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          if (showTitle == true)
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          GestureDetector(
            onTap: () {
              print('Click on Lesson Title');
            },
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 135,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/flutter/images/lesson_banner.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 20,
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            spacing: 2,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today\'s Lesson',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'Lesson Title Here',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
