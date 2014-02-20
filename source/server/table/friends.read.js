function read(query, user, request) {
    
    query.where({fromUserId : user.userId});
    request.execute();
}