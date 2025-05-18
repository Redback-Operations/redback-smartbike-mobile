import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class UserImage extends StatelessWidget {
  // custom constructor
  const UserImage({
    super.key,
    required this.onTap,
    required this.userImage,
    this.updatePic = true,
  });

  final VoidCallback onTap;
  final ImageProvider userImage; // Change the type to ImageProvider
  final bool updatePic;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 65,
          backgroundColor: Colors.transparent,
          backgroundImage: userImage,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: updatePic
              ? SizedBox(
                  height: 40,
                  width: 40,
                  child: InkWell(
                    onTap: onTap,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        color: kLoginRegisterBtnColour,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
