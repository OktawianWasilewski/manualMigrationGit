# define repo table
$table = @(
    "group/repo"
)

# define source instance
$sourceInstance = git@git.example.com:
$targetInstance = git@git.example.com:

# define target instance

foreach ($currentPath in $table) {
    $repoPath = $currentPath
    $repoName = $currentPath.Split("/")[1]
    mkdir complete

    # full clone repo from remote
    git clone --bare $sourceInstance$repoPath.git $repoName
    Set-Location $repoName
    git fetch --all
    git fetch --tags
    git lfs fetch --all

    # convert to lfs and clean up
    cd..
    java -jar bfg-1.14.0.jar --convert-to-git-lfs "*{psd,PSD,jpg,JPG,png,PNG,gif,GIF,bmp,BMP,tga,TGA,tiff,TIFF,iff,IFF,pict,PICT,dds,DDS,xcf,XCF,mp3,MP3,ogg,OGG,wav,WAV,aiff,AIFF,aif,AIF,mod,MOD,it,IT,s3m,S3M,xm,XM,mov,MOV,avi,AVI,asf,ASF,mpg,MPG,mpeg,MPEG,mp4,MP4,fbx,FBX,obj,OBJ,max,MAX,blend,BLEND,dae,DAE,mb,MB,ma,MA,3ds,3DS,dll,DLL,pdb,PDB,zip,ZIP,7z,7Z,gz,GZ,rar,RAR,tar,TAR}" --no-blob-protection $repoName.git
    Set-Location $repoName
    git reflog expire --expire=now --all
    git gc --prune=now --aggressive

    # push all to new server
    git push --set-upstream $targetInstance$repoPath.git
    git remote add mirror $targetInstance$repoPath.git

    cd..
    $currentPath.sp
    $index = $table.IndexOf($currentPath)
    Move-Item $repoName complete/$index+$repoName
}
