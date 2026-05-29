import 'package:flutter/material.dart';

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instructions"),
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🤝 How It Works",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Choose your path:",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "•	One-on-One Accountability Partner\n"
                "•	Mastermind Group Collaboration",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),

              Text(
                "🗂 Forum-Based Matching",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              
              Text(
                "•	Browse posted goals or publish your own\n"
                "•	Click a goal to view the user’s profile\n"
                "•	Connect and schedule a time to talk",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),


            Text(
                "💬 Messaging",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              SizedBox(height: 10),
              Text(
                "•	Free 14-Day Trial includes 3 messages (150 characters max)\n"
                "•	\$5.99 for 6 months includes 10 messages\n"
                "•	Unlimited incoming messages\n"
                "•	Messages are for scheduling only—not full conversations\n"
                "•	Choose your preferred platform: WhatsApp, Zoom, Skype, Teams, phone, or email\n"
                "•	Audio or video chats are encouraged for deeper connection",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),


            Text(
                "📝 Getting Started",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              Text(
                "1. Registration & Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "•	Create your profile: first name, time zone, optional details (gender, age, profession, hobbies)\n"
                "•	Set your availability using the calendar\n"
                "•	Access via Welcome Screen or Menu (top right corner)\n  ",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),

             Text(
                "2. Forum: Post or Search",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "•	Post up to 2 goal topics (visible for 90 days)\n"
                "•	Delete anytime from your profile\n"
                "•	Search by keyword to find aligned partners\n"
                "•	Partner for mutual benefit or simply to support someone’s journey\n",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),


              Text(
                "3. Scheduling",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "•	Click a goal to view the author’s profile\n"
                "•	Coordinate calendars to set a meeting time\n"
                "•	Send a short message to initiate contact\n",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),


              Text(
                "🎯 Apply the Formula",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              SizedBox(height: 10),
              Text(
                "Once connected, create 2–3 SMART accountability statements:\n\n"
                "S.M.A.R.T. Goals\n"
                "•	Specific\n"
                "•	Measurable\n"
                "•	Achievable\n"
                "•	Relevant (connects to your deeper purpose)\n"
                "•	Time-bound (clear deadline)\n"
                "\n"
                "📝 Example:\n"
                "“I am writing and recording an excellent song, having it produced and published within six months to build a social presence, monetize, and raise the collective vibration.”\n"
                "These statements become your shared agreement. Weekly check-ins help you refine strategy, overcome setbacks, and celebrate progress.\n"
                "\n"
                "💡 The Power of Consistency\n"
                "Regular conversations with your partner—rooted in harmony—are the keystone to a vibrant, successful life. You’ll give and receive strength, clarity, and accountability as you move toward your goals.\n\n"
                "🚦 Rules & Respect\n"
                "•	No explicit, violent, or spam content\n"
                "•	No business solicitation or self-promotion\n"
                "•	No private/confidential info beyond contact details\n"
                "•	Forum is for goal statements only—no discussions or advice threads\n\n"
                "🔗 Need Help Finding a Partner?\n"
                "Connect with Avea—Expert Accountability Partner, Life Coach & Psychic: 📧 amylwilhelm@gmail.com 🛍️Fiverr Profile 🔮 Ask Avea Tarot on Etsy \n\n"
                "💌 Subscription Options\n"
                "•	Free 10-Day Trial: 3 messages (150 characters each)\n"
                "•	[Subscribe Now] \$5.99 for 6 months: 10 messages\n"
                "•	All subscriptions renew when message limit is reached\n\n"
                "🌈 Final Thought\n"
                "The first step is yours to take, but the longest journeys are walked side by side. — Z.W.\n",

                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),



              Text(
                "Enjoy your experience with Ally by Avea!",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        )
      )
    );
  }
} 