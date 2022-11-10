import 'package:flutter/material.dart';
import 'package:gulrukh_class/widgets/custom_image.dart';
import 'package:gulrukh_class/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    print("post.mediaUrl ${post.mediaUrl}");
    return GestureDetector(
      onTap: () => print('showing post'),
      child: cachedNetworkImage(post.mediaUrl ?? ""),
    );
  }
}
