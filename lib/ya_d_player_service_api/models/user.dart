class User {
  User({required this.yandexId,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.login,
    required this.sex,
    required this.inviteId,
    required this.createDateTime,
    required this.activateDateTime,
    required this.deactivateDateTime,
    required this.isAdmin
  });

    String yandexId;
    String email;
    String firstname;
    String lastname;
    String login;
    String sex;
    String? inviteId;
    String createDateTime;
    String? activateDateTime;
    String? deactivateDateTime;
    bool isAdmin;
}