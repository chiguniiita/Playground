Param([string]$dir, [string]$branchName, [string]$token)

$dir
$branchName
$token

Compress-Archive -Path $dir\src -DestinationPath $dir\$branchName.zip
Get-Item $dir\$branchName.zip

$assemblies = (
 "Newtonsoft.Json",
 "Newtonsoft.Json.Linq",
 "System",
 "System.IO",
 "System.Net.Http"
)

$source = @"
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.IO;
using System.Net.Http;

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
            var release = new Release(branchName) { body = branchName };
            var json = JsonConvert.SerializeObject(release);
            var res = client.PostAsync("repos/chiguniiita/Playground/releases", new StringContent(json));
            var r = res.Result.Content.ReadAsStringAsync();

            var uploadUrl = JsonConvert.DeserializeObject<JObject>(r.Result)["upload_url"].ToString();

            //zipÇÃí«â¡
            var req = new HttpRequestMessage();
            req.RequestUri = new Uri(uploadUrl.Replace("{?name,label}", "") + "?name=" + branchName + ".zip");
            req.Method = HttpMethod.Post;
            req.Content = new ByteArrayContent(File.ReadAllBytes(Path.Combine(dir, branchName, "zip")));
            req.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/zip");
            var ret = client.SendAsync(req);
            return ret.Result.Content.ReadAsStringAsync().Result;
        }
    }
    public class Release
    {
        public Release(string tagName)
        {
            TagName = tagName;
            Name = tagName;
        }
        [JsonProperty("tag_name")]
        public string TagName { get; }
        [JsonProperty("target_commitish")]
        public string TargetCommitish { get; set; } = "master";
        [JsonProperty("name")]
        public string Name { get; set; }
        [JsonProperty("body")]
        public string body { get; set; }
        [JsonProperty("draft")]
        public bool Draft { get; set; } = false;
        [JsonProperty("prerelease")]
        public bool PreRelease { get; set; } = false;
    }
}
"@

Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $source -Language CSharp
[GitHubReleaseCreator]::Execute($dir, $branchName, $token)
