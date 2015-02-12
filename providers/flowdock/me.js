var me = {

    url: '/user/me',
    params: {},
    fields: {
        id: function(me) {
            return "" + me.id;
        },
        name: 'name',
        company: '=',
        alias: 'nick',
        bio: '=',
        avatar: 'avatar',
        email: 'email',
        location: '='
    }
};

module.exports = me;
