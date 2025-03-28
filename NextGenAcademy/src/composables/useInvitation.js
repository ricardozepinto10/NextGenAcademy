import { supabase } from '@/supabase'

export async function sendInvitation(email, clubId, role) {
  const inviteCode = Math.random().toString(36).slice(-8) // Random 8-character code
  const expiresAt = new Date()
  expiresAt.setDate(expiresAt.getDate() + 7) // Expires in 7 days

  const { data, error } = await supabase
    .from('invitations')
    .insert([{ email, club_id: clubId, role, invite_code: inviteCode, expires_at: expiresAt }])

  if (error) {
    console.error('Error sending invitation:', error)
    return { success: false, error }
  }

  // Send email logic (dummy example)
  await fetch('/api/send-email', {
    method: 'POST',
    body: JSON.stringify({
      to: email,
      subject: 'NextGen Academy Invitation',
      text: `You have been invited to join a club as a ${role}.\n\nUse this code to register: ${inviteCode}`,
    }),
    headers: { 'Content-Type': 'application/json' }
  })

  return { success: true, inviteCode }
}
