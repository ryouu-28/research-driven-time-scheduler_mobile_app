import 'package:flutter/material.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/survey/surveyFirstQuestionPage.dart';

class SurveyStartpage extends StatelessWidget {
  const SurveyStartpage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? size.width * 0.85 : 500,
                ),
                padding: EdgeInsets.all(isMobile ? 24 : 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.schedule,
                        size: isMobile ? 60 : 80,
                        color: Colors.blue,
                      ),
                    ),
                    
                    SizedBox(height: isMobile ? 40 : 50),
                    
                    // Welcome Text
                    Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      "Let's understand your work habits",
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      "Answer a few questions to get personalized scheduling recommendations",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: isMobile ? 50 : 60),
                    
                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 56 : 64,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FirstQuestion(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Let's Start",
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 24),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isMobile ? 30 : 40),
                    
                    // Info text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Takes only 2-3 minutes",
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                color: Colors.white.withOpacity(0.8),
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
          ),
        ),
      ),
    );
  }
}