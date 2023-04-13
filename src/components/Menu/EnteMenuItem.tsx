import {
    MenuItem,
    ButtonProps,
    Box,
    Typography,
    TypographyProps,
} from '@mui/material';
import { CaptionedText } from 'components/CaptionedText';
import PublicShareSwitch from 'components/Collections/CollectionShare/publicShare/switch';
import { SpaceBetweenFlex, VerticallyCenteredFlex } from 'components/Container';
import React from 'react';

interface Iprops {
    onClick: () => void;
    color?: ButtonProps['color'];
    variant?: 'primary' | 'captioned' | 'toggle' | 'secondary';
    fontWeight?: TypographyProps['fontWeight'];
    startIcon?: React.ReactNode;
    endIcon?: React.ReactNode;
    label?: string;
    subText?: string;
    checked?: boolean;
}
export function EnteMenuItem({
    onClick,
    color = 'primary',
    startIcon,
    endIcon,
    label,
    subText,
    checked,
    variant = 'primary',
    fontWeight = 'bold',
}: Iprops) {
    const handleClick = () => {
        onClick();
    };

    return (
        <MenuItem
            onClick={handleClick}
            sx={{
                minWidth: '220px',
                color: (theme) => theme.palette[color].main,
                ...(variant !== 'secondary' && {
                    backgroundColor: (theme) =>
                        theme.colors.background.elevated2,
                }),
                '& .MuiSvgIcon-root': {
                    fontSize: '20px',
                },
                p: 0,
                borderRadius: '4px',
            }}>
            <SpaceBetweenFlex sx={{ pl: '16px', pr: '12px' }}>
                <VerticallyCenteredFlex sx={{ py: '14px' }} gap={'10px'}>
                    {startIcon && startIcon}
                    <Box px={'2px'}>
                        {variant === 'captioned' ? (
                            <CaptionedText mainText={label} subText={subText} />
                        ) : (
                            <Typography fontWeight={fontWeight}>
                                {label}
                            </Typography>
                        )}
                    </Box>
                </VerticallyCenteredFlex>
                <VerticallyCenteredFlex gap={'4px'}>
                    {endIcon && endIcon}
                    {variant === 'toggle' && (
                        <PublicShareSwitch
                            checked={checked}
                            onChange={handleClick}
                        />
                    )}
                </VerticallyCenteredFlex>
            </SpaceBetweenFlex>
        </MenuItem>
    );
}
