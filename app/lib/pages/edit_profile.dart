import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/utilities/constants.dart';
import '../components/main_app_background.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<EditProfile> createState() => _EditProfileActivityState();
}

class _EditProfileActivityState extends State<EditProfile> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _phoneNoController = TextEditingController();

  // for uploading the picture
  PickedFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    // Access the user details from the provider's state
    UserDetails? userDetails =
        Provider.of<UserDataProvider>(context, listen: false).userDetails;

    if (userDetails != null) {
      // Update user details text fields
      setState(() {
        _idController.text = userDetails.id ?? '';
        _firstNameController.text = userDetails.name ?? '';
        _lastNameController.text = userDetails.surname ?? '';
        _usernameController.text = userDetails.username ?? '';
        _dobController.text = userDetails.dob?.toString() ?? '';
        _phoneNoController.text = userDetails.phoneNumber ?? '';
        _emailController.text = userDetails.email ?? '';
      });

      // Set the image file
      if (userDetails.imagePath != null && userDetails.imagePath.isNotEmpty) {
        // If imagePath is not null or empty, fetch the image from the URL
        var response = await http.get(
            Uri.parse('${dotenv.env['API_URL_BASE']}${userDetails.imagePath}'));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/temp_image.jpg');
          await file.writeAsBytes(response.bodyBytes);
          setState(() {
            _imageFile = PickedFile(file.path);
          });
        } else {
          print('Failed to fetch image: ${response.statusCode}');
        }
      }

      // Print or process the user details
      print('User details: $userDetails');
    } else {
      print('User details are null.');
    }
  }

  Future<void> _saveProfile() async {
    // Load the .env file
    await dotenv.load(fileName: ".env");

    // Retrieve the base URL from the environment variables
    String? baseURL = dotenv.env['API_URL_BASE'];

    // Check if the base URL is defined
    if (baseURL != null) {
      // Construct the complete URL by concatenating with the endpoint
      String apiUrl = '$baseURL/update/${_emailController.text}/';

      // Prepare the data you want to send in the PUT request
      var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
      request.fields['id'] = _idController.text;
      request.fields['username'] = _usernameController.text;
      request.fields['name'] = _firstNameController.text;
      request.fields['surname'] = _lastNameController.text;
      request.fields['dob'] = _dobController.text;
      request.fields['phone_number'] = _phoneNoController.text;

      // store the image file
      if (_imageFile != null) {
        // Add the image file to the request
        request.files
            .add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      }

      // create the full path for the image
      String? imagePath;
      if (_imageFile != null) {
        // Extract the file name from the path
        String fileName = _imageFile!.path.split('/').last;

        // Construct the complete image path by combining the base URL and the file name
        imagePath = '/media/images/$fileName';
      } else {
        // If _imageFile is null, set imagePath to an empty string or null, depending on your requirements
        imagePath = ''; // or null
      }

      try {
        // Send the PUT request
        var streamedResponse = await request.send();

        // response ok
        if (streamedResponse.statusCode == 200) {
          print('Profile updated successfully');
          // Update user details in provider
          if (mounted) {
            Provider.of<UserDataProvider>(context, listen: false)
                .updateUserDetails(
              id: _idController.text,
              name: _firstNameController.text,
              surname: _lastNameController.text,
              username: _usernameController.text,
              email: _emailController.text,
              dob: _dobController.text,
              phoneNumber: _phoneNoController.text,
              imagePath: imagePath,
            );
            // notify listeners after updating user details
            Provider.of<UserDataProvider>(context, listen: false)
                .notifyListeners();
          }
        } else {
          // Handle errors here
          print('Failed to update profile: ${streamedResponse.reasonPhrase}');

          // Print response body for more detailed error information
          final responseBody = await streamedResponse.stream.bytesToString();
          print('Response body: $responseBody');
        }
      } catch (e) {
        // Handle network errors here
        print('Error: $e');
      }
    } else {
      // Print a message if BASE_URL is not defined in .env
      print('BASE_URL is not defined in .env file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Scaffold(
        body: SingleChildScrollView(
          child: CustomGradientContainerSoft(
            child: Stack(
              children: [
                Container(
                  child: Center(
                    child: Selector<UserDataProvider, UserDetails?>(
                      selector: (context, userProvider) =>
                          userProvider.userDetails,
                      builder: (context, userDetails, _) {
                        print(
                            '${dotenv.env['API_URL_BASE']}${userDetails?.imagePath}');
                        if (userDetails != null) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 50),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (builder) => bottomSheet(context),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    if (_imageFile != null)
                                      Image.file(
                                        File(_imageFile!.path),
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      )
                                    else
                                      Image.network(
                                        userDetails.imagePath != null &&
                                                userDetails.imagePath.isNotEmpty
                                            ? '${dotenv.env['API_URL_BASE']}${userDetails.imagePath}'
                                            : '${dotenv.env['API_URL_BASE']}/media/images/default.jpeg',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.pinkAccent,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  children: [
                                    // Form Fields
                                    _buildFormField(
                                      'First Name',
                                      _firstNameController,
                                    ),
                                    _buildFormField(
                                      'Last Name',
                                      _lastNameController,
                                    ),
                                    _buildFormField(
                                      'Username',
                                      _usernameController,
                                      enableEditing: false,
                                    ),
                                    _buildFormField(
                                      'Email',
                                      _emailController,
                                      enableEditing: false,
                                    ),
                                    _buildFormField(
                                      'Date of Birth (yyyy-mm-dd)',
                                      _dobController,
                                    ),
                                    _buildFormField(
                                      'Phone Number',
                                      _phoneNoController,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BottomButton(
                                    solidColor: false,
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    buttonText: 'Cancel',
                                  ),
                                  SizedBox(width: 20),
                                  BottomButton(
                                    onTap: () async {
                                      await _saveProfile();
                                      Navigator.of(context).pop();
                                    },
                                    buttonText: 'Save',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          );
                        } else {
                          // Handle when userDetails is null
                          return CircularProgressIndicator(); // Placeholder until data is loaded
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String fieldName, TextEditingController controller,
      {bool enableEditing = true}) {
    // First pass the values from GET request from backend
    controller.text = controller.text.isEmpty ? '' : controller.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: kSubSubTitlePurple,
        ),
        TextFormField(
          controller: controller,
          style: enableEditing
              ? TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              : TextStyle(
                  color: Colors.white54,
                  letterSpacing: 2,
                  fontSize: 20,
                ),

          onTap: enableEditing ? () {} : null,
          enabled: enableEditing,
          // Enable editing when tapped if enableEditing is true
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
        SizedBox(height: 10),
        Divider(
          height: 10,
          thickness: 1,
          color: kLoginRegisterBtnColour,
        ),
      ],
    );
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Text(
              'Chose profile photo',
              style: kSubTitleOfPage,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    choosePhoto(ImageSource.camera);
                  },
                  label: Text("Camera")),
              TextButton.icon(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    choosePhoto(ImageSource.gallery);
                  },
                  label: Text("Gallery")),
            ],
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  void choosePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = PickedFile(pickedFile.path);
      });
    }
  }
}
