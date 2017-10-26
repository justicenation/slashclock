public class SlackApi {
    public class OauthAccessResponse extends Response {
        public String access_token { get; set; }
        public String scope { get; set; }
        public String team_id { get; set; }
        public String team_name { get; set; }
        public String user_id { get; set; }
    }

    public class Icon {
        public String image_34 { get; set; }
        public String image_44 { get; set; }
        public String image_68 { get; set; }
        public String image_88 { get; set; }
        public String image_102 { get; set; }
        public String image_132 { get; set; }
        public Boolean image_default { get; set; }
    }

    public virtual class Response {
        public Boolean ok { get; set; }
    }

    public class Team {
        public String domain { get; set; }
        public String email_domain { get; set; }
        public String enterprise_id { get; set; }
        public String enterprise_name { get; set; }
        public Icon icon { get; set; }
        public String id { get; set; }
        public String name { get; set; }
    }

    public class TeamInfoResponse extends Response {
        public Team team { get; set; }
    }

    public class User {
        public String id { get; set; }
        public String team_id { get; set; }
        public String tz { get; set; }
    }

    public class UsersInfoResponse extends Response {
        public SlackApi.User user { get; set; }
    }
}