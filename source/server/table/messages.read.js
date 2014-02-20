function read(query, user, request) {
    query.where({toUserId : user.userId});
    query.orderByDescending('__createdAt');
    request.execute();

}