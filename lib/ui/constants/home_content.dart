class HomeArticle {
  final String title;
  final String subtitle;
  final String content;
  final String imageUrl;

  const HomeArticle({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
  });
}

class HomeContent {
  static const List<HomeArticle> tutorials = [
    HomeArticle(
      title: "AutoPlan 3D: Sketch to 3D Model in Minutes",
      subtitle: "Learn the core workflow of turning raw hand-drawn boundaries into structured 2D floor plans and immersive 3D environments.",
      imageUrl: "assets/images/home/tutorial_1.jpg",
      content: "To start your journey with AutoPlan 3D, navigate to the 'New Project' section. Begin by sketching your outer boundary—this is the foundation of your home. Ensure your loop is closed so our AI can correctly identify the interior space.\n\nOnce your boundary is set, tap 'Generate AI Floorplan'. Our advanced Graph2Plan engine will analyze your sketch and predict the most logical room distributions, including bedrooms, kitchens, and bathrooms. After generation, you can seamlessly transition to the 3D viewer to walk through your creation in real-time. This workflow reduces hours of manual drafting into just a few minutes of creative input.",
    ),
    HomeArticle(
      title: "Optimizing AI Accuracy: The Orthogonal Wall Secret",
      subtitle: "Discover why drawing straight lines and closed loops is critical for our Graph2Plan engine to generate perfect room distributions.",
      imageUrl: "assets/images/home/tutorial_2.jpg",
      content: "While our AI is highly flexible, the quality of the input directly affects the output. 'Orthogonal' design refers to walls that meet at 90-degree angles. In the world of automated floor planning, horizontal and vertical lines provide the cleanest data for the algorithm to process.\n\nWhen sketching, try to keep your lines as straight as possible. If you need a diagonal wall, ensure it connects cleanly to the rest of the structure. A 'closed loop' is also essential—if there's a gap in your outer boundary, the AI won't know where the 'inside' of the house begins. Following these simple sketching rules will result in much more professional and accurate room layouts.",
    ),
    HomeArticle(
      title: "Mastering Room Adjacency: Kitchens, Lounges, and Flow",
      subtitle: "A deep dive into how our AI understands spatial relationships and how you can guide it for better natural light and movement.",
      imageUrl: "assets/images/home/tutorial_3.jpg",
      content: "Modern architecture is all about 'Flow'—the way people move naturally from one space to another. Our AI models are trained on thousands of professional floor plans to understand that kitchens should ideally be adjacent to dining areas, and master bedrooms should have proximity to bathrooms.\n\nTo guide the AI's spatial logic, consider the shape of your boundary. L-shaped boundaries naturally create 'wings' that the AI might use for private sleeping quarters, while rectangular boundaries favor open-plan living areas. Understanding these relationships allows you to design homes that aren't just aesthetically pleasing, but also functionally superior for everyday living.",
    ),
    HomeArticle(
      title: "Furniture & Fixtures: Placing Windows and Doors",
      subtitle: "Step-by-step instructions on using our automated decoration engine to snap openings into structural walls effectively.",
      imageUrl: "assets/images/home/tutorial_4.jpg",
      content: "Once the rooms are defined, the next step is 'Decoration'—the placement of doors and windows. AutoPlan 3D handles this automatically by detecting external walls for windows and internal partitions for doors.\n\nEach door is placed to ensure clear access paths between rooms, while windows are strategically positioned to maximize natural light based on the room type. For example, living rooms typically receive larger window spans than bathrooms. If you're not satisfied with the automatic placement, you can enter the 'Refine' mode to slide these fixtures along the walls to your preferred position.",
    ),
    HomeArticle(
      title: "Gallery Pro: Showcasing Your Designs to the World",
      subtitle: "How to leverage the Community Gallery to get feedback on your layouts and inspire other architects in the AutoPlan network.",
      imageUrl: "assets/images/home/tutorial_5.jpg",
      content: "The Community Gallery is the social heart of AutoPlan 3D. Exclusive to Pro users, this feature allows you to publish your completed projects for the world to see. It's an incredible way to build a portfolio of your design ideas and see how other users are solving similar spatial challenges.\n\nTo share a project, simply go to your project settings and toggle 'Visibility' to 'Public'. You can add tags and descriptions to help others understand your design philosophy. Engaging with the community by 'liking' and 'cloning' public plans can provide fresh perspectives and accelerate your own design skills.",
    ),
  ];

  static const List<HomeArticle> architectureArticles = [
    HomeArticle(
      title: "The Rise of Generative AI in Residential Architecture",
      subtitle: "How tools like AutoPlan are shifting the paradigm from manual CAD drafting to AI-assisted spatial optimization and rapid prototyping.",
      imageUrl: "assets/images/home/article_1.jpg",
      content: "Generative AI is transforming architecture by moving beyond simple drafting tools into the realm of intelligent design partners. Traditionally, an architect might spend days manually iterating on a floor plan to satisfy all constraints. Today, AI can generate dozens of optimized variations in seconds.\n\nThis shift allows designers to focus more on high-level creativity and client needs rather than the repetitive technicalities of wall placement. AutoPlan 3D is at the forefront of this revolution, putting the power of a professional architectural firm into the hands of every smartphone user, democratizing high-quality home design for everyone.",
    ),
    HomeArticle(
      title: "Maximizing Small Spaces: Studio Apartment Strategies",
      subtitle: "Industry experts share secrets on making 400 sq. ft. feel like 1000 through clever zoning and multi-functional furniture areas.",
      imageUrl: "assets/images/home/article_2.jpg",
      content: "Designing for small spaces is a challenge of 'Micro-Zoning'. The key is to create distinct areas for living, sleeping, and working without using physical walls that would make the space feel cramped.\n\nConsider using 'floating furniture' that doesn't touch the walls, which creates an illusion of more floor area. Multi-functional pieces, like a dining table that doubles as a desk or a bed with built-in storage, are essential. Additionally, using a consistent color palette throughout the entire studio helps the eye travel smoothly across the room, making the overall footprint feel significantly larger than it actually is.",
    ),
    HomeArticle(
      title: "2024 Design Trends: Earthy Tones and Biophilic Textures",
      subtitle: "Why bringing the outside in is the top request for modern homeowners and how to implement it in your digital floor plans.",
      imageUrl: "assets/images/home/article_3.jpg",
      content: "In 2024, the trend is moving away from cold, sterile minimalism toward 'Warm Minimalism'. This involves using earthy tones like terracotta, sage green, and warm ochre to create spaces that feel grounded and peaceful.\n\nBiophilic design—the integration of nature into the built environment—is a huge part of this movement. Incorporating large windows that frame outdoor views, using natural materials like wood and stone, and planning for indoor greenery are all ways to boost the wellbeing of the occupants. When using AutoPlan 3D, you can plan your window placements to ensure your rooms are flooded with the natural light needed for these biophilic elements to thrive.",
    ),
    HomeArticle(
      title: "The Impact of Open Floor Plans on Family Dynamics",
      subtitle: "Is the open-concept living room still relevant? We explore the pros and cons of privacy vs. connectivity in modern housing layouts.",
      imageUrl: "assets/images/home/article_4.jpg",
      content: "The open floor plan has dominated residential design for decades, but family needs are evolving. While open layouts are great for social connectivity and keeping an eye on children, the recent shift toward remote work and home schooling has highlighted the need for 'Acoustic Privacy'.\n\nMany modern designs are now adopting a 'Broken-Plan' approach. This uses elements like internal glass partitions, double-sided fireplaces, or varying floor levels to define separate zones without closing them off entirely with opaque walls. It offers the best of both worlds: the visual spaciousness of an open plan with the functional quietude required for modern life.",
    ),
    HomeArticle(
      title: "Future-Proofing Your Home: Preparing for EV and Solar",
      subtitle: "Technical advice on incorporating infrastructure for renewable energy and smart appliances into your early-stage building designs.",
      imageUrl: "assets/images/home/article_5.jpg",
      content: "Future-proofing a home means designing with the technologies of the next decade in mind. When creating your floor plan, consider the technical requirements of renewable energy. For instance, ensures your roof has a large, south-facing surface area for maximum solar panel efficiency.\n\nIn the garage, plan for high-voltage circuits for Electric Vehicle (EV) chargers. Inside the home, a centralized 'Smart Hub' closet can house all your networking and automation equipment, keeping your living spaces clutter-free. By thinking about these infrastructure needs during the initial design phase in AutoPlan 3D, you can save thousands in renovation costs down the road.",
    ),
  ];
}
