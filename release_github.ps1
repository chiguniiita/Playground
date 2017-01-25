Param([string]$dir, [string]$branchName, [string]$token)

$dir
$branchName
$token

Compress-Archive -Path $dir -DestinationPath $dir\$branchName.zip
Get-Item $dir\$branchName.zip

$assemblies = (
"System.Net.Http",
"System.Runtime.Serialization",
"System.Xml"
)

$source = @"
using System;
using System.IO;
using System.Net.Http;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;

public class GitHubReleaseCreator
{
    public static string Execute(string dir, string branchName, string token)
    {
        using (var client = new HttpClient())
        {
            client.BaseAddress = new Uri("https://api.github.com/");
            client.DefaultRequestHeaders.Add("Authorization", "token " + token);
            client.DefaultRequestHeaders.UserAgent.Add(new System.Net.Http.Headers.ProductInfoHeaderValue("Mozilla", "5.0"));

            //ReleaseçÏê¨
            var release = new ReleaseInputData
            {
                tag_name = branchName,
                target_commitish = "master",
                name = branchName,
                body = branchName,
                draft = false,
                prerelease = false
            };
            var json = Serialize(release);
            var res = client.PostAsync("repos/chiguniiita/Playground/releases", new StringContent(json));
            var r = res.Result.Content.ReadAsStringAsync();
            var releaseData = Deserialize<ReleaseData>(r.Result);

            //zipÇÃí«â¡
            var req = new HttpRequestMessage();
            req.RequestUri = new Uri(releaseData.upload_url.Replace("{?name,label}", "") + "?name=" + branchName + ".zip");
            req.Method = HttpMethod.Post;
            req.Content = new ByteArrayContent(File.ReadAllBytes(Path.Combine(dir, branchName + ".zip")));
            req.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/zip");
            var ret = client.SendAsync(req);
            return ret.Result.Content.ReadAsStringAsync().Result;
        }
    }
    private static string Serialize<T>(T o)
    {
        using (var ms = new MemoryStream())
        using (var sr = new StreamReader(ms))
        {
            var serializer = new DataContractJsonSerializer(typeof(T));
            serializer.WriteObject(ms, o);
            ms.Position = 0;

            return sr.ReadToEnd();
        }
    }
    private static T Deserialize<T>(string s)
    {
        using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(s)))
        {
            var serializer = new DataContractJsonSerializer(typeof(T), new DataContractJsonSerializerSettings
            {
                DateTimeFormat = new DateTimeFormat("yyyy-MM-dd'T'HH:mm:ssZ")
            });
            return (T)serializer.ReadObject(ms);
        }
    }

    [DataContract]
    public class ReleaseInputData
    {
        [DataMember]
        public string tag_name { get; set; }
        [DataMember]
        public string target_commitish { get; set; }
        [DataMember]
        public string name { get; set; }
        [DataMember]
        public string body { get; set; }
        [DataMember]
        public bool draft { get; set; }
        [DataMember]
        public bool prerelease { get; set; }
    }

    [DataContract]
    public class ReleaseData
    {
        [DataMember]
        public string url { get; set; }
        [DataMember]
        public string assets_url { get; set; }
        [DataMember]
        public string upload_url { get; set; }
        [DataMember]
        public string html_url { get; set; }
        [DataMember]
        public int id { get; set; }
        [DataMember]
        public string tag_name { get; set; }
        [DataMember]
        public string target_commitish { get; set; }
        [DataMember]
        public string name { get; set; }
        [DataMember]
        public bool draft { get; set; }
        [DataMember]
        public Author author { get; set; }
        [DataMember]
        public bool prerelease { get; set; }
        [DataMember]
        public DateTime created_at { get; set; }
        [DataMember]
        public DateTime published_at { get; set; }
        [DataMember]
        public object[] assets { get; set; }
        [DataMember]
        public string tarball_url { get; set; }
        [DataMember]
        public string zipball_url { get; set; }
        [DataMember]
        public string body { get; set; }
    }

    [DataContract]
    public class Author
    {
        [DataMember]
        public string login { get; set; }
        [DataMember]
        public int id { get; set; }
        [DataMember]
        public string avatar_url { get; set; }
        [DataMember]
        public string gravatar_id { get; set; }
        [DataMember]
        public string url { get; set; }
        [DataMember]
        public string html_url { get; set; }
        [DataMember]
        public string followers_url { get; set; }
        [DataMember]
        public string following_url { get; set; }
        [DataMember]
        public string gists_url { get; set; }
        [DataMember]
        public string starred_url { get; set; }
        [DataMember]
        public string subscriptions_url { get; set; }
        [DataMember]
        public string organizations_url { get; set; }
        [DataMember]
        public string repos_url { get; set; }
        [DataMember]
        public string events_url { get; set; }
        [DataMember]
        public string received_events_url { get; set; }
        [DataMember]
        public string type { get; set; }
        [DataMember]
        public bool site_admin { get; set; }
    }
}
"@

Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $source -Language CSharp
[GitHubReleaseCreator]::Execute($dir, $branchName, $token)
