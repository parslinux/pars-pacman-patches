#!/bin/bash
# ==========================================================
# PARS WRAPPER SCRIPT
# Gerçek pacman teknolojisini Pars markası ve güvenliğiyle sunar
# ==========================================================

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Pars logosu / başlığı
echo -e "${BLUE}🐆 Pars Paket Yöneticisi (Powered by Pacman)${NC}"

# Sisteme dokunan bir işlem mi? (-S, -U, -R, -y ile kombinasyonları)
if [[ "$1" == "-S"* || "$1" == "-U"* || "$1" == "-R"* ]]; then
    
    # Root yetkisi var mı kontrol et
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Bu işlem root yetkisi gerektirir, sudo ile yeniden başlatılıyor...${NC}"
        exec sudo /usr/bin/pars "$@"
    fi

    echo -e "${GREEN}🛡️ Pars: İşlem öncesi Btrfs snapshot alınıyor...${NC}"
    
    # Btrfs snapshot al (eğer kök dizin Btrfs ise)
    if mount | grep -q "on / type btrfs"; then
        SNAPSHOT_NAME="pre-pars-$(date +%Y%m%d-%H%M%S)"
        btrfs subvolume snapshot -r / /.snapshots/$SNAPSHOT_NAME 2>/dev/null && \
            echo -e "${GREEN}✅ Snapshot alındı: $SNAPSHOT_NAME${NC}" || \
            echo -e "${YELLOW}⚠️  Snapshot alınamadı (izin hatası olabilir)${NC}"
    else
        echo -e "${YELLOW}ℹ️  Kök dizin Btrfs değil, snapshot atlanıyor${NC}"
    fi
fi

# Tüm argümanları ($@) olduğu gibi gerçek pacman'e ilet
exec /usr/bin/pacman "$@"
