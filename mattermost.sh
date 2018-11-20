#!/bin/sh
nohup mattermost >/dev/null 2>&1 & 
sleep 30
until nc -z localhost 8000; do
    sleep 5
done
userName=$MATTERMOST_SYSTEM_USER_NAME
passWord=$MATTERMOST_SYSTEM_USER_PASSWD
email=$MATTERMOST_SYSTEM_USER_EMAIL
baseApiUrl=http://localhost:8000/mattermost/api/v4
if [[ "$userName" = "" || "$passWord" = "" || "$email" = "" ]];then
    echo "システムユーザ名、パスワード、メールを入力してください。"
    exit 1
fi

userNameSearchFlg=`mattermost user search $userName 2>&1 | wc -l`
emailSearchFlg=`mattermost user search $email 2>&1 | wc -l`
if [ "$userNameSearchFlg" = "1" ] ; then
    if [ "$emailSearchFlg" = "1" ] ; then
        mattermost user create --system_admin --email $email --username $userName --password $passWord
        if [ $? != 0 ];then
            echo "システムユーザを作成することが失敗しました！"
        	exit 1
        fi
	else
        echo "重複メールのユーザが存在しました！"
        exit 1
	fi
else
    if [ "$emailSearchFlg" = "1"  ] ; then
        echo "重複ユーザ名のユーザが存在しました！"
        exit 1
	else
        echo "重複ユーザ名、メールのユーザが存在しました！"
	fi
fi

token=`curl -i -d '{"login_id":"'$userName'","password":"'$passWord'"}' $baseApiUrl/users/login | awk -F "[ \r\n]" '/Token/{print $2}'`

systemUserInfo=`curl -H 'Authorization: Bearer '$token $baseApiUrl/roles/name/system_user`
userId=`echo $systemUserInfo | jq .id | awk -F  '"' '{print $2}'`
updateRoleInfo=${systemUserInfo/\,\"create_team\"/}

curl -X PUT -H 'Authorization: Bearer '$token -d $updateRoleInfo $baseApiUrl/roles/$userId/patch

config=`curl -H 'Authorization: Bearer '$token $baseApiUrl/config | sed 's/"RequireEmailVerification":false/"RequireEmailVerification":true/g' | sed 's/"EnableUserCreation":true/"EnableUserCreation":false/g'`

curl -X PUT -H 'Authorization: Bearer '$token -d "$config" $baseApiUrl/config 
tail -f /dev/null
