function insert(item, user, request) {
    item.fromUserId = user.userId;
    item.toUserId = user.userId;
    item.rocketFileId = '';
    request.execute();

}