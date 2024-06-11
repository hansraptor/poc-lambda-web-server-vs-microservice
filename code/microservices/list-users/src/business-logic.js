
async function annotateUsers(users) {
    if (!users) {
        users = [];
    }

    return users.map(user => {
        user.readstamp = (new Date()).getDate();

        return user;
    });
};

module.exports = {
    annotateUsers: annotateUsers
};
