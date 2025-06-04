
scons platform=windows target=template_debug arch=x86_64 module_mono_enabled=yes precision=double production=yes
scons platform=windows target=template_release arch=x86_64 module_mono_enabled=yes precision=double production=yes generate_bundle=true
