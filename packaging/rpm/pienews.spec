Name:           pienews
Version:        %{version}
Release:        1%{?dist}
Summary:        PieNews RSS Reader
License:        MIT
URL:            https://github.com/jasen/pienews
BuildArch:      x86_64
Requires:       gtk3, libnotify

%description
A modern RSS reader built with Flutter.

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/512x512/apps
mkdir -p %{buildroot}/usr/lib/%{name}

# Copy application files
cp -r %{_sourcedir}/* %{buildroot}/usr/lib/%{name}/
ln -s /usr/lib/%{name}/%{name} %{buildroot}/usr/bin/%{name}

# Create desktop file
cat > %{buildroot}/usr/share/applications/%{name}.desktop << EOF
[Desktop Entry]
Name=PieNews
Comment=RSS Reader
Exec=/usr/lib/%{name}/%{name}
Icon=%{name}
Terminal=false
Type=Application
Categories=Network;News;
StartupWMClass=pienews
EOF

# Copy icon
cp %{_sourcedir}/data/flutter_assets/assets/icons/app_icon.png %{buildroot}/usr/share/icons/hicolor/512x512/apps/%{name}.png

%files
/usr/bin/%{name}
/usr/lib/%{name}
/usr/share/applications/%{name}.desktop
/usr/share/icons/hicolor/512x512/apps/%{name}.png

%post
update-desktop-database &> /dev/null || :
gtk-update-icon-cache /usr/share/icons/hicolor &> /dev/null || :

%postun
update-desktop-database &> /dev/null || :
gtk-update-icon-cache /usr/share/icons/hicolor &> /dev/null || :

%changelog
* Wed Apr 24 2024 PieNews Team <your.email@example.com> - %{version}-1
- Initial RPM release
