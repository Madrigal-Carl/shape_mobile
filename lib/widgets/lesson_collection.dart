import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class LessonCollectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> lessons;
  final String title;

  const LessonCollectionWidget({
    super.key,
    required this.lessons,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/lessonSession',
                        arguments: lesson,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            lesson['image'],
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lesson['title'],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              alignment: Alignment.centerRight,
                              child: GFProgressBar(
                                percentage: lesson['progress'] / 100,
                                animationDuration: 1500,
                                lineHeight: 18,
                                animation: true,
                                alignment: MainAxisAlignment.spaceBetween,
                                linearGradient: LinearGradient(
                                  colors: [
                                    Color(0xFF247BFF),
                                    Color(0xFF2BB4EE),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                child: Text(
                                  '${lesson['progress']}%',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
