param(
  [string]$camrec,
  [int]$recordingWidth = 1024,
  [int]$recordingHeight = 768
)

if($camrec.Length -eq 0 -or -not $camrec.EndsWith('.camrec')) {
  'Usage: New-Camproj Recording.camrec [-recordingWidth 1024] [-recordingHeight 768]'
  exit(0)
}

$camrecFile = resolve-path $camrec

$camproj = [xml]@"
<?xml version="1.0"?>
<Project_Data Version="6.00">
<Project_Settings>
<ProfileName>Recording Dimensions</ProfileName>
<ProjectWidth>###DATA###</ProjectWidth>
<ProjectHeight>###DATA###</ProjectHeight>
<ClipbinOption>0</ClipbinOption>
<IsCustomProject>1</IsCustomProject>
<SavedProjectSettings>1</SavedProjectSettings>
<MediaFolderPath>###DATA###</MediaFolderPath>
<LastFlashTemplate>-1</LastFlashTemplate>
<ResizeOption>0</ResizeOption>
</Project_Settings>

<UI_Layout>
<Video>1</Video>
<AudioOne>1</AudioOne>
<AudioTwo>0</AudioTwo>
<Zoom>0</Zoom>
<Callout>0</Callout>
<PIP>0</PIP>
<PIPAudio>0</PIPAudio>
<Questions>0</Questions>
<Caption>0</Caption>
<AudioThree>0</AudioThree>
<VideoSelected>1</VideoSelected>
<VideoAudioSelected>0</VideoAudioSelected>
<AudioTwoSelected>1</AudioTwoSelected>
<PIPSelected>1</PIPSelected>
<PIPAudioSelected>0</PIPAudioSelected>
<CaptionSelected>1</CaptionSelected>
<AudioThreeSelected>1</AudioThreeSelected>
<Video1AndAudio1Linked>1</Video1AndAudio1Linked>
<PIPVideoAndAudioLinked>1</PIPVideoAndAudioLinked>
<Bookmarks>0</Bookmarks>
</UI_Layout>

<AutoSaveFile></AutoSaveFile>

<PowerPointProject>0</PowerPointProject>

<PowerPointFilename></PowerPointFilename>

<DockPIP>1</DockPIP>
<ZoomPanHints>1</ZoomPanHints>
<ClipBin_Array>
<ClipBin_Object>
<ClipName></ClipName>
</ClipBin_Object>
</ClipBin_Array>

<DShowControl_ClipMap>
<DShowControl_ClipMap_Object>
<FileName>###DATA##</FileName>
<PPTFile></PPTFile>
<FromPPT>0</FromPPT>
<Track>1</Track>
<ClipIndex>0</ClipIndex>
<Flags>8</Flags>
<Start>0</Start>
<End>0</End>
<ClipHasAudio>1</ClipHasAudio>
<BitsPerPixel>0</BitsPerPixel>
<Width>###DATA###</Width>
<Height>###DATA###</Height>
<FileLength>0</FileLength>
<MarkIn>0</MarkIn>
<MarkOut>0</MarkOut>
<MediaStart>0</MediaStart>
<MediaEnd>0</MediaEnd>
<FrameRate>0.000000</FrameRate>
<ClipSpeed>1.000000</ClipSpeed>
<WFSize>0</WFSize>
<WFAvgBytesPerSec>44100</WFAvgBytesPerSec>
<WFBlockAlign>2</WFBlockAlign>
<WFChannels>1</WFChannels>
<WFSamplesPerSec>22050</WFSamplesPerSec>
<WFBitsPerSample>16</WFBitsPerSample>
<WFFormatTag>1</WFFormatTag>
<ClipMapIndex>1</ClipMapIndex>
<ClipTitle>###DATA###</ClipTitle>
<PowerPointSlide>0</PowerPointSlide>
<SplitMinStart>0</SplitMinStart>
<SplitMinEnd>0</SplitMinEnd>
<Extra>0</Extra>
<BuddyID>0</BuddyID>
</DShowControl_ClipMap_Object>
</DShowControl_ClipMap>

<PIP_Array>
</PIP_Array>

<Zoom_Array>
</Zoom_Array>

<Overlay_Array>
</Overlay_Array>

<Bookmark_Array>
</Bookmark_Array>

<QuestionGroup_Array>
</QuestionGroup_Array>

<DShowControl_Edit_Array>
</DShowControl_Edit_Array>

<Title_Array>
</Title_Array>

<Caption_Array>
<MaxCaptionLength>32</MaxCaptionLength>
<AlwaysDisplay>0</AlwaysDisplay>
<OverlayCaptions>1</OverlayCaptions>
<ShowCaptions>1</ShowCaptions>
</Caption_Array>

<NoiseFilterInfo>
<AudioVocalEnhancement>0</AudioVocalEnhancement>
<AudioGlobalBypass>0</AudioGlobalBypass>
<AudioTraining>0</AudioTraining>
<AudioClippingReduction>0</AudioClippingReduction>
<AudioClickReduction>0</AudioClickReduction>
<AudioNoiseReduction>0</AudioNoiseReduction>
<AudioClickSensitivity>0.50</AudioClickSensitivity>
<AudioNoiseReduction>1.00</AudioNoiseReduction>
<AudioNoiseSensitivity>1.00</AudioNoiseSensitivity>
<AudioCompressionOn>0</AudioCompressionOn>
<AudioCompressionPreset>1</AudioCompressionPreset>
<AudioCurRatio>20.00</AudioCurRatio>
<AudioCurThreshold>-30.00</AudioCurThreshold>
<AudioCurGain>5.00</AudioCurGain>
<AudioCurAttack>1.00</AudioCurAttack>
<AudioCurRelease>200.00</AudioCurRelease>
<AudioCustRatio>20.00</AudioCustRatio>
<AudioCustThreshold>-30.00</AudioCustThreshold>
<AudioCustGain>5.00</AudioCustGain>
<AudioCustAttack>1.00</AudioCustAttack>
<AudioCustRelease>200.00</AudioCustRelease>
</NoiseFilterInfo>

<Project_Notes>
</Project_Notes>

<Project_MetaData>
<Project_MetaData_Object>
<FieldArrayKey>16</FieldArrayKey>
<Value>ENU</Value>
</Project_MetaData_Object>
</Project_MetaData>

</Project_Data>
"@

$settings = $camproj.Project_Data.Project_Settings
$settings.ProjectWidth = [string]$recordingWidth
$settings.ProjectHeight = [string]$recordingHeight
$settings.MediaFolderPath = [string](split-path $camrecFile.Path)

$camproj.Project_Data.ClipBin_Array.ClipBin_Object.ClipName = [string]$camrecFile.Path

$clip = $camproj.Project_Data.DShowControl_ClipMap.DShowControl_ClipMap_Object
$clip.FileName = "tscrec6://{0}!screen_stream.avi" -f $camrecFile.Path
$clip.Width = [string]$recordingWidth
$clip.Height = [string]$recordingHeight
$clip.ClipTitle = [string](split-path $camrecFile.Path -leaf)

function AppendMetadata([System.Xml.XmlElement]$parent, [int]$position, [string]$value) {
  $metadataValue = "<FieldArrayKey>{0}</FieldArrayKey><Value>{1}</Value>" -f $position, $value
  $metadataNode = $parent.OwnerDocument.CreateElement('Project_MetaData_Object')
  $metadataNode.set_InnerXml($metadataValue)
  $parent.AppendChild($metadataNode)
}

$metadata = $camproj.Project_Data.Project_MetaData
$name = [System.IO.Path]::GetFilenameWithoutExtension($camrecFile.Path)
AppendMetadata $metadata 8 $name
AppendMetadata $metadata 9 'Extreme ASP.NET Makeover'
AppendMetadata $metadata 13 ([System.DateTime]::Now)

$camproj.Save([System.IO.Path]::ChangeExtension($camrecFile.Path, '.camproj'))