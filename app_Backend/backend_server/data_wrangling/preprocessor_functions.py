from ..models import MyUser

# TODO: implement when creating a user (signing in) ; does the same as the script in models.py - lines 24-32


def generate_user_id(user):
    """
    generate a unique user ID starting at 1000 for each new user.

    Parameters:
    - user: A MyUser object.

    Returns:
    - user_id: The generated user ID.
    """
    last_user = MyUser.objects.order_by('-id').first()
    if last_user:
        last_id = int(last_user.id)
    else:
        last_id = 999  # Starting from 1000
    user_id = str(last_id + 1)  # Increment the id
    return user_id
