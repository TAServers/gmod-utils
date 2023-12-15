SWEP.PrintName = "Hands"
SWEP.Author = "TAS Team"
SWEP.Contact = "https://taservers.com/"
SWEP.Instructions =
	"Right-click while walking and crouching to toggle the crosshair"
SWEP.IconOverride = "entities/weapon_fists.png"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "normal"
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true

	function SWEP:DrawWorldModel() end
	function SWEP:DrawWorldModelTranslucent() end
else
	function SWEP:ShouldDropOnDie()
		return false
	end

	function SWEP:OnDrop()
		if SERVER then
			self:Remove()
		end
	end
end

function SWEP:Initialize()
	self:DrawShadow(false)
	self:SetHoldType("normal")
	self:SetSequence("ragdoll") -- Along with the viewmodel, makes the hands invisible
end

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack()
	if
		not IsFirstTimePredicted()
		or not self.Owner:IsWalking()
		or not self.Owner:Crouching()
	then
		return
	end
	self.DrawCrosshair = not self.DrawCrosshair
	self:SetNextSecondaryFire(CurTime() + 0.3)
end
