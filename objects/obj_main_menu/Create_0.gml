/// @desc Configuration du Menu Principal

// Liste des options du menu
options = [
    "HEBERGER UNE PARTIE",
    "REJOINDRE UN AMI",
    "ENTRAÎNEMENT",
    "PLEIN ÉCRAN",
    "QUITTER"
];

menu_count = array_length(options);
menu_index = 0;

// Propriétés visuelles et animations
menu_x = 120;
menu_y_start = 320;
menu_item_height = 55;

// Tableau pour animer l'échelle de chaque bouton individuellement
item_scales = array_create(menu_count, 1.0);