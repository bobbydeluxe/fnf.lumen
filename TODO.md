# 🌟 FNF: Lumen Engine TODO

- [ ] Backport new dialogue textboxes from p-slice 3.0 update

- [ ] New song playstate functions [skip results screen, change the state that it exits to, etc.]
    - This could possibly allow for almost every state [except the title screen and main menu bc limitations] to be coded using lua, actually, due to hooking it up to different songs.

- [ ] Polish the editors (Character Editor, Chart Editor, etc.)
    - Character Editor tweaks in mind
        - add a silhouette of girlfriend for `gf` style characters, like how there are images for guidance on `boyfriend` and `dad` style characters in psych
        - new background n' stuff
    - Chart Editor tweaks
        - add mini characters to help with chart visualization [from emi03/victoria's untitled psych fork, she coded the chart editor characters rlly good]
        - re-add song metadata section to chart editor

- [ ] Add aesthetic tweaks to Options menu (colors, spacing, slight animations)

- [ ] Edit to Brazilian Portuguese translations and slight rework of translation `.lang` file placement
    - I might have my friend Tutyshow2017 help as he even speaks the language

- [ ] Diamond tiles transition effect [by Moonlight_Catalyst]
    - I just need to properly optimize it

- [ ] Style the FPS counter (font, background box, color pulse on drop)

- [ ] Application Icons and stuff

- [ ] Add a new rating above "Sick" (Probably gonna bring back my interpretation of the scrapped "Killer" rating from base FNF)
    - counts as sick in results screen because i can't edit the results FLA since i don't have adobe animate

- [ ] Create a new hitsound (distinct from Psych/P-Slice default)

- [ ] Tweak ease lerping on stuff (health icons, camera zoom, etc.)
    - I did this in my Henry's Wrath recode build, so im re-implementing it here

- [ ] Add Change Character event fix script [by Ledonic]
    - The issue is that using the Change Character event is bugged if characters have a shader